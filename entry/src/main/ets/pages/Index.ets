import * as ApiUser from '../apis/auto/demo/ApiUser';
import router from '@ohos.router';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import { promptAction } from '@kit.ArkUI';
import { fileUri } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UserSearchDrawer } from '../components/UserSearchDrawer';
import { UserListItem } from '../components/UserListItem';
import { ListFooterStatus } from '../components/ListFooterStatus';
import { Want } from '@kit.AbilityKit';
import { GetUserPagedResponse, UserInfoDto, UserPageQueryDto } from '../apis/auto/demo/model';

@Entry
@Component
struct Index {
  @State users: UserInfoDto[] = [];
  @State total: number = 0;
  @State refreshing: boolean = false;
  @State page: number = 1;
  @State loadingMore: boolean = false;
  @State noMore: boolean = false; // 是否没有更多
  // 搜索相关状态
  @State showSearch: boolean = false; // 是否展示搜索侧栏
  @State queryCode: string = '';
  @State queryName: string = '';
  @State statusIndex: number = 0; // 0=全部 1=启用 2=禁用
  @State queryStatus: boolean | undefined = undefined; // 实际传给接口的布尔状态
  // 搜索组件内已包含状态选项文案
  // 底部 Actions 弹层显示控制
  @State showActions: boolean = false;
  // 导出状态
  @State exporting: boolean = false; // 是否正在导出
  // 最近导出的文件信息（用于打开文件）
  @State exportedFilePath: string = '';
  // 删除状态
  @State deleting: boolean = false; // 是否正在删除

  private async fetchPage(page: number, append: boolean = false) {
    const res: GetUserPagedResponse = await ApiUser.getUserPaged({
      pagination: { page, limit: 10 },
      code: this.queryCode ? this.queryCode : undefined,
      name: this.queryName ? this.queryName : undefined,
      status: this.queryStatus,
    } as UserPageQueryDto);
    if (res && res.results) {
      const newList = res.results as UserInfoDto[];
      if (append) {
        this.users = this.users.concat(newList);
      } else {
        this.users = newList;
      }
      this.total = res.total;
      this.noMore = this.users.length >= this.total;
    }
    this.loadingMore = false;
    this.refreshing = false;
  }

  private loadMore() {
    if (this.loadingMore || this.noMore) {
      return;
    }
    this.loadingMore = true;
    this.page++;
    this.fetchPage(this.page, true);
  }

  aboutToAppear() {
    // 页面加载时请求用户分页数据
    this.page = 1;
    this.noMore = false;
    this.fetchPage(this.page, false);
  }

  // 应用搜索条件
  private applySearch() {
    this.showSearch = false;
    this.page = 1;
    this.noMore = false;
    this.fetchPage(this.page, false);
  }

  // 清空搜索条件
  private clearSearch() {
    this.queryCode = '';
    this.queryName = '';
    this.statusIndex = 0;
    this.queryStatus = undefined;
  }

  /**
   * 导出当前查询条件下的用户列表为 Excel 文件
   * 调用后端接口获取二进制并写入到应用文件目录
   */
  private async handleExport() {
    const uiContext = this.getUIContext();
    const prompt = uiContext.getPromptAction();
    try {
      this.exporting = true;
      // 触发下载请求；后端若为空字符串则忽略筛选
      const resp = await ApiUser.exportUsers({
        code: this.queryCode || '',
        name: this.queryName || '',
        email: '' // 当前界面没有 email 筛选,传空即可
      });

      if (!resp || !resp.data) {
        console.warn('导出失败：响应为空');
        try {
          prompt.showToast({ message: '导出失败' });
        } catch (toastErr) {
          console.error('显示提示失败:', toastErr);
        }
        return;
      }

      // 获取上下文文件目录；若不可用使用标准内部存储路径兜底
      const context = uiContext.getHostContext();
      const baseDir = (context && (context.filesDir || context.cacheDir)) ?? '/data/storage/el2/base/files';
      const safeName = (resp.name || 'users.xlsx').replace(/[\\\/]/g, '_');
      const filePath = baseDir + '/' + safeName;

      let file: fs.File | undefined;
      try {
        file = await fs.open(filePath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
        await fs.write(file.fd, resp.data);
        console.info('用户数据已导出: ' + filePath);
        this.exportedFilePath = filePath;

        // 显示成功对话框，提供打开文件选项
        prompt.showDialog({
          title: '导出成功',
          message: `文件已保存至:\n${filePath}`,
          buttons: [
            { text: '关闭', color: '#666666' },
            { text: '打开文件', color: '#007AFF' }
          ]
        }).then((result) => {
          if (result.index === 1) {
            // 用户点击"打开文件"
            this.openExportedFile();
          }
        }).catch((err: BusinessError) => {
          console.error('对话框错误:', JSON.stringify(err));
        });
      } catch (writeErr) {
        console.error('写入导出文件失败:', JSON.stringify(writeErr));
        try {
          prompt.showToast({ message: '文件写入失败' });
        } catch (toastErr) {
          console.error('显示提示失败:', toastErr);
        }
      } finally {
        if (file) {
          try {
            await fs.close(file.fd);
          } catch { /* ignore */
          }
          file = undefined;
        }
      }
    } catch (e) {
      console.error('导出异常:', JSON.stringify(e));
      try {
        prompt.showToast({ message: '导出异常' });
      } catch (toastErr) {
        console.error('显示提示失败:', toastErr);
      }
    } finally {
      this.showActions = false;
      this.exporting = false;
    }
  }

  /**
   * 打开最近导出的文件
   */
  private async openExportedFile() {
    const uiContext = this.getUIContext();
    const prompt = uiContext.getPromptAction();
    if (!this.exportedFilePath) {
      try {
        prompt.showToast({ message: '没有可打开的文件' });
      } catch (toastErr) {
        console.error('显示提示失败:', toastErr);
      }
      return;
    }

    try {
      const context = uiContext.getHostContext() as common.UIAbilityContext;
      const uri = fileUri.getUriFromPath(this.exportedFilePath);

      // 尝试方式1: 使用具体的 Excel MIME type
      let want: Want = {
        action: 'ohos.want.action.viewData',
        uri: uri,
        type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      };

      try {
        await context.startAbility(want);
        console.info('文件打开成功: ' + uri);
        return;
      } catch (firstErr) {
        console.warn('第一次打开失败，尝试通用方式:', JSON.stringify(firstErr));

        // 尝试方式2: 使用通用文件类型
        want = {
          action: 'ohos.want.action.viewData',
          uri: uri,
          type: 'application/octet-stream'
        };

        try {
          await context.startAbility(want);
          console.info('使用通用方式打开成功: ' + uri);
          return;
        } catch (secondErr) {
          console.warn('第二次打开失败，尝试不指定类型:', JSON.stringify(secondErr));

          // 尝试方式3: 不指定 type，让系统自动识别
          want = {
            action: 'ohos.want.action.viewData',
            uri: uri
          };

          await context.startAbility(want);
          console.info('使用系统识别方式打开成功: ' + uri);
        }
      }
    } catch (err) {
      const errCode = (err as BusinessError)?.code || 0;
      console.error('打开文件失败:', JSON.stringify(err));

      let message = '打开文件失败';
      if (errCode === 16000050) {
        message = '未找到可打开此文件的应用，请安装 WPS 或其他办公软件';
      } else if (errCode === 16000001) {
        message = '文件路径无效';
      } else {
        message = `打开文件失败 (错误码: ${errCode})`;
      }

      try {
        prompt.showToast({
          message: message,
          duration: 3000
        });
      } catch (toastErr) {
        console.error('显示提示失败:', toastErr);
      }
    }
  }

  /**
   * 删除用户
   */
  private async handleDelete(user: UserInfoDto) {
    const uiContext = this.getUIContext();
    const prompt = uiContext.getPromptAction();
    try {
      // 显示确认对话框
      const result = await prompt.showDialog({
        title: '确认删除',
        message: `确定要删除用户 "${user.name}" 吗？此操作不可恢复。`,
        buttons: [
          { text: '取消', color: '#666666' },
          { text: '删除', color: '#FF3B30' }
        ]
      });

      // 用户点击删除
      if (result.index === 1) {
        this.deleting = true;
        try {
          await ApiUser.removeUser({ id: user.id });
          try {
            prompt.showToast({ message: '删除成功' });
          } catch (toastErr) {
            console.error('显示提示失败:', toastErr);
          }

          // 从列表中移除该用户
          this.users = this.users.filter(u => u.id !== user.id);
          this.total = this.total - 1;

          // 如果当前页没有数据了，且不是第一页，则重新加载上一页
          if (this.users.length === 0 && this.page > 1) {
            this.page--;
            this.fetchPage(this.page, false);
          }
        } catch (err) {
          console.error('删除用户失败:', JSON.stringify(err));
          try {
            prompt.showToast({ message: '删除失败，请稍后重试' });
          } catch (toastErr) {
            console.error('显示提示失败:', toastErr);
          }
        } finally {
          this.deleting = false;
        }
      }
    } catch (err) {
      console.error('显示对话框失败:', JSON.stringify(err));
    }
  }

  build() {
    // 使用 Stack 以便在最上层叠加搜索抽屉
    Stack() {
      // 主列表区域
      Column() {
        // 顶部标题栏
        Row() {
          Blank()
            .width(20)
          Text('User Management')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
          Image($r('app.media.search'))
            .width(30)
            .height(30)
            .margin({ right: 10 })
            .objectFit(ImageFit.Contain)
            .onClick(() => {
              this.showSearch = true
            })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        .width('100%') // 设置宽度占满
        // 使用 vp（逻辑像素）而不是 px，避免在不同密度设备上过小；并增加上下内边距提升视觉高度
        .height(56)
        .padding({ top: 12, bottom: 12 })
        .backgroundColor('#f3f4f8')
        .flexShrink(0)

        Refresh({
          refreshing: this.refreshing,
        }) {
          List() {
            ForEach(this.users, (item: UserInfoDto) => {
              UserListItem({
                user: item,
                onDelete: (user: UserInfoDto): Promise<void> => this.handleDelete(user)
              })
            }, (user: UserInfoDto) => user.name)
            // 尾部加载/结束/空状态
            ListFooterStatus({
              loadingMore: this.loadingMore,
              noMore: this.noMore,
              dataCount: this.users.length,
              refreshing: this.refreshing
            })
          }
          .edgeEffect(EdgeEffect.Spring)
          .onReachEnd(() => {
            this.loadMore();
          })
        }.onRefreshing(
          () => {
            this.refreshing = true;
            this.page = 1;
            this.noMore = false;
            this.fetchPage(this.page, false);
          })
        .layoutWeight(1) // 占据剩余空间，避免与顶部/底部重叠

        // 底部操作栏（右侧操作块）
        Row() {
          // 右侧 Actions 区域（改为普通容器 Row，保留原样式与点击）
          Row() {
            Text('Actions')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Medium)
              .margin({ right: 4 })
            Text('▾')
              .fontSize(32)
              .fontColor('#FFFFFF')
              .opacity(0.9)
              .margin({ left: 6 })
          }
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .height('100%')
          .padding({ left: 16, right: 12 })
          .backgroundColor('#233A6B')
          .onClick(() => {
            this.showActions = true;
          })
        }
        .width('100%')
        .height(48) // 调整高度更贴近设计稿
        .justifyContent(FlexAlign.End)
        .alignItems(VerticalAlign.Center)
        .backgroundColor('#FFFFFF')
        .border({ width: { top: 0.5 }, color: '#E5E5E5' })
      }
      .position({})
      .backgroundColor('#F7F8FA')
      .height('100%')
      .width('100%')

      // 搜索抽屉组件
      UserSearchDrawer({
        showSearch: $showSearch,
        queryCode: $queryCode,
        queryName: $queryName,
        statusIndex: $statusIndex,
        queryStatus: $queryStatus,
        confirm: (): void => this.applySearch(),
        clear: (): void => this.clearSearch()
      })

      // 底部 Actions 弹出面板
      if (this.showActions) {
        // 遮罩
        Column() {
          Blank()
            .layoutWeight(1)
            .onClick(() => {
              this.showActions = false;
            })
          // 弹出主体
          Column() {
            // 选项：Add User
            Text('Add User')
              .width('100%')
              .textAlign(TextAlign.Center)
              .fontSize(16)
              .fontColor('#333')
              .padding({ top: 18, bottom: 18 })
              .onClick(() => {
                this.showActions = false;
                router.pushUrl({
                  url: 'pages/UserDetail',
                  params: {
                    isEdit: false
                  }
                });
              })
            Divider().color('#E8E8EC').height(1)
            // 选项：Export
            Text('Export')
              .width('100%')
              .textAlign(TextAlign.Center)
              .fontSize(16)
              .fontColor('#333')
              .padding({ top: 18, bottom: 18 })
              .onClick(() => {
                this.handleExport();
              })
          }
          .backgroundColor('#F9F9FC')
          .borderRadius({
            topLeft: 24,
            topRight: 24,
            bottomLeft: 0,
            bottomRight: 0
          })
          .shadow({
            color: '#00000022',
            radius: 12,
            offsetX: 0,
            offsetY: -2
          })
        }
        .height('100%')
        .width('100%')
        .backgroundColor('#00000044')
        // 移除 HorizontalAlign.Stretch（版本不支持），保持默认拉伸
        .justifyContent(FlexAlign.End)
      }
      // 导出加载遮罩
      if (this.exporting) {
        Column() {
          LoadingProgress().width(48).height(48).margin({ bottom: 12 })
          Text('正在导出...').fontSize(14).fontColor('#FFF')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#00000055')
      }

      // 删除加载遮罩
      if (this.deleting) {
        Column() {
          LoadingProgress().width(48).height(48).margin({ bottom: 12 })
          Text('正在删除...').fontSize(14).fontColor('#FFF')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#00000055')
      }

    }
  }
}