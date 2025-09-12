import { fetchUserPage } from '../api/UserApi';
import { UserInfoDto } from '../types/UserApiTypes';

@Entry
@Component
struct Index {
  @State users: UserInfoDto[] = [];
  @State total: number = 0;
  @State refreshing: boolean = false;

  aboutToAppear() {
    // 页面加载时请求用户分页数据
    fetchUserPage({
      pagination: { page: 1, limit: 10 },
      code: '',
      name: '',
      status: undefined
    }, (res) => {
      if (res && res.results) {
        this.users = res.results as UserInfoDto[];
        this.total = res.total;
      }
    });
  }

  build() {
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
        .width('30px').height('30px').margin({ right: 10 })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .width('100%') // 设置宽度占满
      .height('100px')
      .backgroundColor('#f3f4f8')
      .flexShrink(0)

      // 用户列表，支持下拉刷新
      Refresh({
        refreshing: this.refreshing,
      }) {
        Scroll() {
          Column() {
            ForEach(this.users, (item: UserInfoDto) => {
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
                  Image($r(`app.media.${item.avatar}`))
                    .width(80)
                    .height(100)
                    .borderRadius(10)
                  Column() {
                    Text(`Gender: ${item.gender}`).fontSize(14)
                    Text(`Email: ${item.email}`).fontSize(14)
                    Text(`Address: ${item.address}`).fontSize(14)
                    Text(`Created Time: ${item.createdAt}`).fontSize(13).fontColor('#888')
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
            }, (user: UserInfoDto) => user.name)
          }.padding({ top: 12 })
        }
        .height('calc(100% - 200px)')
        .align(Alignment.Top)
      }.onRefreshing(
        () => {
          this.refreshing = true;
          fetchUserPage({
            pagination: { page: 1, limit: 10 },
            code: '',
            name: '',
          }, (res) => {
            if (res && res.results) {
              this.users = res.results as UserInfoDto[];
              this.total = res.total;
            }
            this.refreshing = false;
          });
        })

      // 底部操作栏
      Row() {
        Blank()
          .flexGrow(1)
        Button('Actions')
          .fontSize(16)
          .backgroundColor('#233A6B')
          .fontColor('#fff')
          .borderRadius(0)
          .width(140)
          .height('100px')
      }
      .width('100%')
      .height('100px')
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#FFFFFF')
    }
    .backgroundColor('#F7F8FA')
    .height('100%')
    .width('100%')
  }
}