// 使用 axios 改造接口调用
import { UserPageQueryDto, GetUserPagedResponse } from '../../../types/UserApiTypes';
import * as base from './base'


/**
 * 用户分页查询接口
 * @param req 查询参数
 */
export const fetchUserPage = base.createJsonRequest<UserPageQueryDto, GetUserPagedResponse>((req) => ({
  url: '/user/paged',
  method: 'POST',
  data: req
}))
