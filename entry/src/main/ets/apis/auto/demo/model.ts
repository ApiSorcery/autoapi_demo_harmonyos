import { AxiosProgressEvent, FormData } from "@ohos/axios";

export interface File {
  /** File content */
  data: ArrayBuffer;

  /** File type */
  type: string;

  /** File name */
  fileName: string;
}

export interface TFormData {
  toFormData(): FormData;
}

/** Batch export users (Excel) request parameters */
export interface ExportUsersRequest {
  /** User code */
  code: string;

  /** User name */
  name: string;

  /** Email address */
  email: string;
}

/** Get single user request parameters */
export interface GetUserOneRequest {
  /** User ID */
  id: number;
}

/** Delete user request parameters */
export interface RemoveUserRequest {
  /** User ID */
  id: number;
}

/** Validate if user code exists request parameters */
export interface ValidateCodeRequest {
  /** User code */
  code: string;
}

/** Delete file request parameters */
export interface DeleteFileRequest {
  /** File UUID */
  id: string;
}

/** Get file request parameters */
export interface GetFileRequest {
  /** File UUID */
  id: string;
}

/** Upload file request parameters */
export class UploadFileRequest implements TFormData {
  /** File to upload */
  file?: File;

  /** File description (optional) */
  description?: string;

  /** Upload progress callback function */
  onUploadProgress?: (progressEvent: AxiosProgressEvent) => void;

  constructor(file?: File, description?: string, onUploadProgress?: (progressEvent: AxiosProgressEvent) => void) {
    this.file = file;
    this.description = description;
    this.onUploadProgress = onUploadProgress;
  }

  toFormData(): FormData {
    const formData = new FormData();
    formData.append('file', this.file?.data, { filename: this.file?.fileName, type: this.file?.type });
    formData.append('description', this.description);
    return formData;
  }
}

/** Query user list with pagination response parameters */
export interface GetUserPagedResponse {
  results: Array<UserInfoDto>;

  total: number;
}

export interface ResultData {
  /**
   * Status code
   */
  status: number;

  /**
   * Status description
   */
  message: string;

  /**
   * Response data
   */
  data: any;

}

export interface UserInfoDto {
  /**
   * User ID
   */
  id: number;

  /**
   * User code
   */
  code: string;

  /**
   * User name
   */
  name: string;

  /**
   * Email
   */
  email: string;

  /**
   * Gender
   */
  gender?: number;

  /**
   * Avatar
   */
  avatar?: string;

  /**
   * Address
   */
  address?: string;

  /**
   * Status
   */
  status?: boolean;

  /**
   * Created time
   */
  createdAt: string;

  /**
   * Updated time
   */
  updatedAt?: string;

}

export interface Pagination {
  /**
   * Page number
   */
  page?: number;

  /**
   * Items per page
   */
  limit?: number;

  /**
   * Sort field
   */
  sortBy?: string;

  /**
   * Sort order
   */
  order?: string;

}

export interface UserPageQueryDto {
  /**
   * Pagination parameters
   */
  pagination?: Pagination;

  /**
   * User code
   */
  code?: string;

  /**
   * User name
   */
  name?: string;

  /**
   * User status
   */
  status?: boolean;

}

export interface UserAddRequestDto {
  /**
   * User code
   */
  code: string;

  /**
   * User name
   */
  name: string;

  /**
   * Email
   */
  email: string;

  /**
   * Gender
   */
  gender?: number;

  /**
   * Avatar
   */
  avatar?: string;

  /**
   * Address
   */
  address?: string;

  /**
   * Status
   */
  status?: boolean;

}

export interface UserModifyRequestDto {
  /**
   * User ID
   */
  id: number;

  /**
   * User code
   */
  code?: string;

  /**
   * User name
   */
  name?: string;

  /**
   * Email
   */
  email?: string;

  /**
   * Gender
   */
  gender?: number;

  /**
   * Avatar
   */
  avatar?: string;

  /**
   * Address
   */
  address?: string;

  /**
   * Status
   */
  status?: boolean;

}
