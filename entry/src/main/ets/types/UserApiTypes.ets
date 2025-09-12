export interface ResultData<T> {
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
  data: T;

}

// 用户相关接口类型定义
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

/** Query user list with pagination response parameters */
export interface GetUserPagedResponse {
  results: Array<UserInfoDto>;

  total: number;
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
