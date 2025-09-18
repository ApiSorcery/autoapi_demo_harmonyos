import router from '@ohos.router';

@Entry
@Component
struct AddUser {
  @State code: string = '';
  @State name: string = '';
  @State email: string = '';
  @State genderIndex: number = 0; // 0 female 1 male (示例)
  @State status: boolean = true;
  @State address: string = '';
  @State avatar: string = '';
  // 底部 Actions 弹层显示控制
  @State showActions: boolean = false;

  private goBack() {
    router.back();
  }

  private saveUser() {
    // TODO: 接入真实创建用户 API
    console.info('保存用户占位:', JSON.stringify({
      code: this.code,
      name: this.name,
      email: this.email,
      gender: this.genderIndex,
      status: this.status,
      address: this.address,
      avatar: this.avatar
    }));
    router.back();
  }

  build() {
    Stack() {
      Column() {
        // 顶部栏
        Row() {
          Image($r('app.media.back'))
            .width(24).height(24)
            .margin({ right: 8 })
            .onClick(() => this.goBack())
          Text('Add User').fontSize(20).fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .height(48)
        .alignItems(VerticalAlign.Center)
        .padding({ left: 12 })
        .backgroundColor('#F7F8FA')

        // 表单区域
        Column() {
          // Code
          Text('* Code:').fontColor('#333').fontSize(14).margin({ bottom: 4 })
          TextInput({ placeholder: 'Please enter' })
            .width('100%')
            .height(40)
            .border({ width: 1, color: '#DDD', radius: 6 })
            .padding({ left: 12, right: 12 })
            .onChange((v: string) => this.code = v)
          if (!this.code) {
            Text('Cannot be empty').fontColor('#c00').fontSize(10).margin({ top: 4, bottom: 8 })
          } else {
            Blank().height(8)
          }

          // Name
          Text('* Name:').fontColor('#333').fontSize(14).margin({ bottom: 4 })
          TextInput({ placeholder: 'Please enter' })
            .width('100%')
            .height(40)
            .border({ width: 1, color: '#DDD', radius: 6 })
            .padding({ left: 12, right: 12 })
            .onChange((v: string) => this.name = v)
          if (!this.name) {
            Text('Cannot be empty').fontColor('#c00').fontSize(10).margin({ top: 4, bottom: 8 })
          } else {
            Blank().height(8)
          }

          // Email
          Text('* Email:').fontColor('#333').fontSize(14).margin({ bottom: 4 })
          TextInput({ placeholder: 'Please enter' })
            .width('100%')
            .height(40)
            .border({ width: 1, color: '#DDD', radius: 6 })
            .padding({ left: 12, right: 12 })
            .onChange((v: string) => this.email = v)
          if (!this.email) {
            Text('Cannot be empty').fontColor('#c00').fontSize(10).margin({ top: 4, bottom: 8 })
          } else {
            Blank().height(8)
          }

          // Gender (简单选择器)
          Text('Gender:').fontColor('#333').fontSize(14).margin({ bottom: 4 })
          Row() {
            Text(this.genderIndex === 0 ? 'Female' : 'Male')
              .fontSize(14)
              .padding({
                left: 12,
                right: 12,
                top: 10,
                bottom: 10
              })
              .border({ width: 1, color: '#DDD', radius: 6 })
              .onClick(() => {
                this.genderIndex = (this.genderIndex + 1) % 2
              })
          }.margin({ bottom: 16 })

          // Status
          Text('Status:').fontColor('#333').fontSize(14).margin({ bottom: 4 })
          Toggle({ type: ToggleType.Switch, isOn: this.status })
            .onChange((v: boolean) => this.status = v)
          Blank().height(16)

          // Address
          Text('Address:').fontColor('#333').fontSize(14).margin({ bottom: 4 })
          TextArea({ placeholder: 'Please enter' })
            .width('100%')
            .height(90)
            .border({ width: 1, color: '#DDD', radius: 6 })
            .padding({
              left: 12,
              right: 12,
              top: 8,
              bottom: 8
            })
            .onChange((v: string) => this.address = v)
          Blank().height(24)

          // Avatar 占位
          Text('Avatar:').fontColor('#333').fontSize(14).margin({ bottom: 8 })
          Row() {
            Image($r('app.media.image_placeholder'))
              .width(100)
              .height(100)
              .backgroundColor('#F0F0F3')
              .border({ width: 1, color: '#DDD', radius: 8 })
              .objectFit(ImageFit.Contain)
              .onClick(() => { /* TODO 选择图片 */
              })
          }

          Blank().height(40)
        }
        .padding({ left: 20, right: 20, top: 12 })
        .layoutWeight(1)
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .layoutWeight(1) // 占据剩余空间，避免与顶部/底部重叠

        // 底部按钮
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
      .height('100%')
      .width('100%')
      .backgroundColor('#FFFFFF')

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
            Text('Save')
              .width('100%')
              .textAlign(TextAlign.Center)
              .fontSize(16)
              .fontColor('#233A6B')
              .backgroundColor('#E8EAF2')
              .padding({ top: 18, bottom: 18 })
              .onClick(() => {
                this.showActions = false;
                this.saveUser();
              })
            Divider().color('#E8E8EC').height(1)
            // 选项：Export
            Text('Cancel')
              .width('100%')
              .textAlign(TextAlign.Center)
              .fontSize(14)
              .fontColor('#555')
              .backgroundColor('#F5F5F7')
              .padding({ top: 18, bottom: 18 })
              .onClick(() => {
                this.showActions = false;
                this.goBack();
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
