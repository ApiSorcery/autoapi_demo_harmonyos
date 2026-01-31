import dateUtil from '../utils/DateUtil';
import { UserInfoDto } from '../apis/auto/demo/model';

@Component
export struct UserListItem {
  @Prop user: UserInfoDto = {} as UserInfoDto; // 由父组件传入
  onDelete?: (user: UserInfoDto) => void; // 删除回调函数

  private navigateToDetail() {
    this.getUIContext().getRouter().pushUrl({
      url: 'pages/UserDetail',
      params: {
        userId: this.user.id,
        isEdit: true
      }
    }).catch(() => {
      // handle error
    });
  }

  // 删除按钮的构建器
  @Builder
  deleteButton() {
    Row() {
      Text('删除')
        .fontSize(16)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Medium)
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .width(80)
    .height('100%')
    .backgroundColor('#FF3B30')
    .onClick(() => {
      if (this.onDelete) {
        this.onDelete(this.user);
      }
    })
  }

  build() {
    ListItem() {
      Column() {
        Row() {
          Text(`${this.user.name} - ${this.user.code}`)
            .fontWeight(FontWeight.Bold)
            .fontSize(16)
          Blank()
          Text(this.user.status ? 'Enabled' : 'Disabled')
            .fontColor(this.user.status === true ? '#007AFF' : '#FF5A5F')
            .fontSize(15)
            .margin({ right: 10 })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 10 })

        Divider().color('#E0E0E0').height(1)
        Row() {
          Image(this.user.avatar)
            .width(80)
            .height(100)
            .borderRadius(10)
          Column() {
            Text(`Gender: ${this.user.gender}`).fontSize(14)
            Text(`Email: ${this.user.email}`).fontSize(14)
            Text(`Address: ${this.user.address}`).fontSize(14)
            Text(`Created Time: ${dateUtil.formatToCST(this.user.createdAt)}`).fontSize(13)
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
      .onClick(() => {
        this.navigateToDetail();
      })
    }
    .swipeAction({ end: this.deleteButton() })
  }
}