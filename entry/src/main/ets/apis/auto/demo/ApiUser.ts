/// User
import * as base from './base';
import * as Model from './model';

/**
 * Add user
 */
export const addUser = base.createJsonRequest<Model.UserAddRequestDto,number>((data) => ({
  url: `/user`,
  method: 'POST',
  data
}))

/**
 * Batch export users (Excel)
 */
export const exportUsers = base.createDownloadRequest<Model.ExportUsersRequest>((params) => ({
  url: `/user/export`,
  method: 'GET',
  params,
}))

/**
 * Get single user
 */
export const getUserOne = base.createJsonRequest<Model.GetUserOneRequest,Model.UserInfoDto>((req) => ({
  url: `/user/${req.id}`,
  method: 'GET',
}))

/**
 * Query user list with pagination
 */
export const getUserPaged = base.createJsonRequest<Model.UserPageQueryDto,Model.GetUserPagedResponse>((data) => ({
  url: `/user/paged`,
  method: 'POST',
  data
}))

/**
 * Modify user information
 */
export const modifyUser = base.createJsonRequest<Model.UserModifyRequestDto>((data) => ({
  url: `/user`,
  method: 'PATCH',
  data
}))

/**
 * Delete user
 */
export const removeUser = base.createJsonRequest<Model.RemoveUserRequest>((req) => ({
  url: `/user/${req.id}`,
  method: 'DELETE',
}))

/**
 * Validate if user code exists
 */
export const validateCode = base.createJsonRequest<Model.ValidateCodeRequest,boolean>((params) => ({
  url: `/user/validateCode`,
  method: 'GET',
  params,
}))
