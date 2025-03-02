export const isEncrypted: (path: string) => boolean;
export const extractSync: (path: string, dest: string, password?: string) => void;
export const extract: (path: string, dest: string, password?: string) => Promise<void>;