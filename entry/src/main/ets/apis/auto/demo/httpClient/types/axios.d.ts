export interface Result<T = any> {
  status: number
  data: T
  message: string
}

/** Binary data response type */
export interface BlobResp {
  /** File content */
  data: ArrayBuffer;

  /** File type */
  type: string;

  /** File name */
  name: string;
}
