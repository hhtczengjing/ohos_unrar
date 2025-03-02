#include "napi/native_api.h"
#include <hilog/log.h>
#include "rar.hpp"
#include "dll.hpp"

#define _UNIX
#define NM  2048
#define LOG(...) OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_DOMAIN, "wtf_c", __VA_ARGS__);
using namespace std;


struct ExtractCallBack {
    napi_async_work work;
    napi_ref callbackRef = nullptr; // 用于callback模式
    napi_deferred deferred;         // 用于promise模式
    std::string path;
    std::string dest2;
    std::string password;
    bool flag = false; //是否有输入密码
    std::string result = "";
    std::string value = "";
    bool ret = false;
};

const wchar_t *CgetWC(wchar_t *dest, const char *src) {
    const size_t cSize = strlen(src) + 1;
    mbstowcs(dest, src, cSize);
    return dest;
}

char *wchar2char(char *dest, wchar_t *WStr) {
    const size_t len = wcslen(WStr) + 1;
    wcstombs(dest, WStr, len);
    return dest;
}

static napi_value napi_isEncrypted(napi_env env, napi_callback_info info) {
    wchar_t nameW[NM];
    struct RAROpenArchiveDataEx data {};
    memset(nameW, 0, sizeof(char) * NM);

    size_t requireArgc = 1;
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    char buf[1024];
    size_t size = 1024;
    napi_get_value_string_utf8(env, args[0], buf, size, &size);
    std::string path = buf;
    char *paths = buf;
    CgetWC(nameW, paths);

    size_t len = wcslen(nameW) + 1;
    char *CStr = (char *)malloc(len * sizeof(char));
    wchar2char(CStr, nameW);

    double mode;
    mode = RAR_OM_EXTRACT;

    data.ArcNameW = nameW;
    data.OpenMode = (unsigned int)mode;
    HANDLE handle = RAROpenArchiveEx(&data);
    if (handle == nullptr || data.OpenResult) {
        if (handle) {
            RARCloseArchive(handle);
        }
        char err_str[128];
        napi_throw_error(env, err_str, "RarException");
        return 0;
    }

    napi_value sum;
    if (data.Flags == ROADF_ENCHEADERS) {
        LOG(" buf =  加密");
        napi_create_int32(env, 1, &sum);

    } else {
        struct RARHeaderDataEx header {};
        bool tag2 = true;
        while (!RARReadHeaderEx(handle, &header)) {
            if (header.Flags == RHDF_ENCRYPTED) {
                tag2 = false;
                break;
            }
        }
        if (tag2) {
            LOG(" buf =  没加密 ");
            napi_create_int32(env, 0, &sum);
        } else {
            LOG(" buf =  加密");
            napi_create_int32(env, 1, &sum);
        }
    }
    if (handle) {
        RARCloseArchive(handle);
    }
    return sum;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        { "isEncrypted", nullptr, napi_isEncrypted, nullptr, nullptr, nullptr, napi_default, nullptr }
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "unrar",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterUnrarModule(void)
{
    napi_module_register(&demoModule);
}
