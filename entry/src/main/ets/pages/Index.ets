import { fetchUserPage } from '../api/UserApi';
import router from '@ohos.router';
import { UserInfoDto } from '../types/UserApiTypes';
import { UserSearchDrawer } from '../components/UserSearchDrawer';
import { UserListItem } from '../components/UserListItem';
import { ListFooterStatus } from '../components/ListFooterStatus';

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

  private fetchPage(page: number, append: boolean = false) {
    fetchUserPage({
      pagination: { page, limit: 10 },
      code: this.queryCode ? this.queryCode : undefined,
      name: this.queryName ? this.queryName : undefined,
      status: this.queryStatus,
    }, (res) => {
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
    });
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
              UserListItem({ user: item })
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
                router.pushUrl({ url: 'pages/AddUser' });
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
                // TODO: 接入导出逻辑
                this.showActions = false;
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
    }
  }
}