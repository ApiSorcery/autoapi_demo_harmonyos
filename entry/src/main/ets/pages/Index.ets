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
  // 搜索相关状态
  @State showSearch: boolean = false; // 是否展示搜索侧栏
  @State queryCode: string = '';
  @State queryName: string = '';
  @State statusIndex: number = 0; // 0=全部 1=启用 2=禁用
  @State queryStatus: boolean | undefined = undefined; // 实际传给接口的布尔状态
  // 状态选项文案
  private statusOptions: string[] = ['All', 'Enabled', 'Disabled'];

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

      // 搜索抽屉 & 遮罩
      if (this.showSearch) {
        // 遮罩 + 右侧抽屉
        Row() {
          // 点击空白处关闭
          Blank()
            .flexGrow(1)
            .onClick(() => {
              this.showSearch = false
            })
          // 抽屉主体
          Column() {
            Text('Quick Search')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 20 })

            // 用户代码
            Column() {
              Text('User Code:')
                .fontSize(14)
                .fontColor('#333')
              TextInput({ text: this.queryCode, placeholder: 'Input user code' })
                .margin({ top: 6 })
                .height(36)
                .padding({ left: 8, right: 8 })
                .fontSize(14)
                .backgroundColor('#F5F6F8')
                .borderRadius(6)
                .onChange(v => {
                  this.queryCode = v
                })
            }.margin({ bottom: 16 })
            .alignItems(HorizontalAlign.Start)

            // 用户姓名
            Column() {
              Text('User Name:')
                .fontSize(14)
                .fontColor('#333')
              TextInput({ text: this.queryName, placeholder: 'Input user name' })
                .margin({ top: 6 })
                .height(36)
                .padding({ left: 8, right: 8 })
                .fontSize(14)
                .backgroundColor('#F5F6F8')
                .borderRadius(6)
                .onChange(v => {
                  this.queryName = v
                })
            }.margin({ bottom: 16 })
            .alignItems(HorizontalAlign.Start)

            // 用户状态选择
            Column() {
              Text('User Status:')
                .fontSize(14)
                .fontColor('#333')
                .margin({ bottom: 6 })
              Row() {
                ForEach(this.statusOptions, (label: string, idx: number) => {
                  Text(label)
                    .fontSize(13)
                    .fontColor(this.statusIndex === idx ? '#233A6B' : '#555')
                    .backgroundColor(this.statusIndex === idx ? '#E5ECF8' : '#F2F3F5')
                    .padding({
                      left: 10,
                      right: 10,
                      top: 6,
                      bottom: 6
                    })
                    .borderRadius(14)
                    .margin({ right: 8 })
                    .onClick(() => {
                      this.statusIndex = idx;
                      if (idx === 0) {
                        this.queryStatus = undefined;
                      } else if (idx === 1) {
                        this.queryStatus = true;
                      } else {
                        this.queryStatus = false;
                      }
                    })
                }, (label: string) => label)
              }.margin({ top: 6 })
            }.margin({ bottom: 24 })
            .alignItems(HorizontalAlign.Start)

            Blank().flexGrow(1)

            // 操作按钮
            Row() {
              Button('Clear')
                .height(44)
                .fontSize(15)
                .backgroundColor('#FFFFFF')
                .fontColor('#233A6B')
                .border({
                  width: {
                    top: 1,
                    bottom: 1,
                    left: 1,
                    right: 1
                  },
                  color: '#233A6B'
                })
                .borderRadius(22)
                .onClick(() => {
                  this.clearSearch()
                })
                .layoutWeight(1)
                .margin({ right: 12 })
              Button('Confirm')
                .height(44)
                .fontSize(15)
                .backgroundColor('#233A6B')
                .fontColor('#fff')
                .borderRadius(22)
                .onClick(() => {
                  this.applySearch()
                })
                .layoutWeight(1)
            }
          }
          .width('70%')
          .height('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .shadow({
            color: '#00000022',
            radius: 8,
            offsetX: -2,
            offsetY: 0
          })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#00000055')
      }
    }
  }
}