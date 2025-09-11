import { UserInfo } from '../types/UserInfo';

@Entry
@Component
struct Index {
  private users: UserInfo[] = [
    {
      name: 'Wu Song',
      username: 'songwu',
      status: 'Enabled',
      gender: 'Female',
      email: 'songwu@126.com',
      address: 'No. 5, Songjia Road',
      created: '2025-07-02 14:45:05',
      avatar: 'background'
    },
    {
      name: 'San Song',
      username: 'songsan',
      status: 'Enabled',
      gender: 'Female',
      email: 'songyi@126.com',
      address: 'No. 3, Songjia Road',
      created: '2025-07-02 14:20:55',
      avatar: 'background'
    },
    {
      name: 'Er Song',
      username: 'songer',
      status: 'Disabled',
      gender: 'Female',
      email: 'songyi@126.com',
      address: 'No. 2, Songjia Road',
      created: '2025-07-02 14:20:33',
      avatar: 'background'
    },
    {
      name: 'Yi Song',
      username: 'songyi',
      status: 'Enabled',
      gender: 'Female',
      email: 'songyi@126.com',
      address: 'No. 1, Songjia Road',
      created: '2025-07-02 14:20:10',
      avatar: 'background'
    }
  ];

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

      // 用户列表
      Scroll() {
        Column() {
          ForEach(this.users, (user: UserInfo) => {
            Column() {
              Row() {
                Text(`${user.name} - ${user.username}`)
                  .fontWeight(FontWeight.Bold)
                  .fontSize(16)
                Blank()
                Text(user.status)
                  .fontColor(user.status === 'Enabled' ? '#007AFF' : '#FF5A5F')
                  .fontSize(15)
                  .margin({ right: 10 })
                // 箭头图标可自定义
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .margin({ bottom: 10 })

              Divider().color('#E0E0E0').height(1)
              Row() {
                Image($r(`app.media.${user.avatar}`))
                  .width(80)
                  .height(100)
                  .borderRadius(10)
                Column() {
                  Text(`Gender: ${user.gender}`).fontSize(14)
                  Text(`Email: ${user.email}`).fontSize(14)
                  Text(`Address: ${user.address}`).fontSize(14)
                  Text(`Created Time: ${user.created}`).fontSize(13).fontColor('#888')
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
            .margin({ bottom:12, left: 8, right: 8 })
            .padding(10)
            .shadow({
              color: '#eee',
              radius: 4,
              offsetX: 0,
              offsetY: 2
            })
          }, (user: UserInfo) => user.username)
        }.padding({top:12})
      }
      .height('calc(100% - 200px)')
      .align(Alignment.Top)

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