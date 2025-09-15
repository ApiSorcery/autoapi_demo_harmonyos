import { fetchUserPage } from '../api/UserApi';
import { UserInfoDto } from '../types/UserApiTypes';
import { formatToCST } from '../utils/DateUtil';

@Entry
@Component
struct Index {
  @State users: UserInfoDto[] = [];
  @State total: number = 0;
  @State refreshing: boolean = false;
  @State page: number = 1;
  @State loadingMore: boolean = false;
  @State noMore: boolean = false; // 是否没有更多

  private fetchPage(page: number, append: boolean = false) {
    fetchUserPage({
      pagination: { page, limit: 10 },
      code: '',
      name: '',
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

  build() {
    // 根容器：直接使用 Column，并通过 safeArea 修饰符（如果版本支持）或顶部 padding 兼容
    Column() {
      // 顶部标题栏
      Row() {
        Blank()
          .width(20)
        Text('User Management')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
        Button() {
          // 菜单图标可自定义
        }
        .width(30).height(30).margin({ right: 10 })
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
          ForEach(this.users, (item: UserInfoDto, index: number) => {
            ListItem() {
              Column() {
                Row() {
                  Text(`${item.name} - ${item.code}`)
                    .fontWeight(FontWeight.Bold)
                    .fontSize(16)
                  Blank()
                  Text(item.status ? 'Enabled' : 'Disabled')
                    .fontColor(item.status === true ? '#007AFF' : '#FF5A5F')
                    .fontSize(15)
                    .margin({ right: 10 })
                  // 箭头图标可自定义
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                .margin({ bottom: 10 })
                Divider().color('#E0E0E0').height(1)
                Row() {
                  Image(item.avatar)
                    .width(80)
                    .height(100)
                    .borderRadius(10)
                  Column() {
                    Text(`Gender: ${item.gender}`).fontSize(14)
                    Text(`Email: ${item.email}`).fontSize(14)
                    Text(`Address: ${item.address}`).fontSize(14)
                    Text(`Created Time: ${formatToCST(item.createdAt)}`).fontSize(13)
                  }.margin({ left: 10 })
                  .height(100)
                  .alignItems(HorizontalAlign.Start)
                  .justifyContent(FlexAlign.SpaceBetween)
                }
                .width('100%')
                .margin({ top: 10 })
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .backgroundColor('#fff')
              .borderRadius(8)
              .margin({ bottom: 12, left: 8, right: 8 })
              .padding(10)
              .shadow({
                color: '#eee',
                radius: 4,
                offsetX: 0,
                offsetY: 2
              })
            }
          }, (user: UserInfoDto) => user.name)
          // 尾部加载/结束指示
          ListItem() {
            if (this.loadingMore) {
              Row() {
                // 使用 LoadingProgress 代替 Progress() 无参调用，避免“Expected 1 arguments”错误
                LoadingProgress()
                  .width(30)
                  .height(30)
                Text(' 正在加载...')
                  .fontSize(14)
                  .margin({ left: 6 })
              }.width('100%').justifyContent(FlexAlign.Center).padding(20)
            } else if (this.noMore && this.users.length > 0) {
              Text('—— 没有更多数据 ——')
                .fontSize(12)
                .fontColor('#999')
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding(20)
            } else if (this.users.length === 0 && !this.refreshing) {
              Text('暂无数据')
                .fontSize(14)
                .fontColor('#999')
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding(40)
            }
          }
        }
        // 正常布局下仅需要常规底部间距
        .padding({ bottom: 16 })
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

      // 底部操作栏（自然流布局）
      Row() {
        Blank()
          .flexGrow(1)
        Button('Actions')
          .fontSize(16)
          .backgroundColor('#233A6B')
          .fontColor('#fff')
          .borderRadius(0)
          .width(140)
          .height(56)
      }
      .width('100%')
      .height(56)
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#FFFFFF')
      .border({ width: { top: 0.5 }, color: '#E5E5E5' })
    }
    .position({})
    .backgroundColor('#F7F8FA')
    .height('100%')
    .width('100%')
    // 由于当前版本不支持 safeArea 修饰符，这里使用固定顶部内边距（如需适配不同设备，可改为动态计算）
    .padding({ top: 12 })
  }
}