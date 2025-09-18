@Component
export struct UserSearchDrawer {
  // 控制显示
  @Link showSearch: boolean;
  // 查询字段的双向绑定
  @Link queryCode: string;
  @Link queryName: string;
  @Link statusIndex: number; // 0 all 1 enabled 2 disabled
  @Link queryStatus: boolean | undefined;

  // 事件：确认、清空
  confirm?: () => void;
  clear?: () => void;

  private statusOptions: string[] = ['All', 'Enabled', 'Disabled'];

  build() {
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
              .onChange(v => { this.queryCode = v })
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
              .onChange(v => { this.queryName = v })
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
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .borderRadius(14)
                  .margin({ right: 8 })
                  .onClick(() => {
                    this.statusIndex = idx;
                    if (idx === 0) { this.queryStatus = undefined; }
                    else if (idx === 1) { this.queryStatus = true; }
                    else { this.queryStatus = false; }
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
              .border({ width: { top: 1, bottom: 1, left: 1, right: 1 }, color: '#233A6B' })
              .borderRadius(22)
              .onClick(() => { this.clear && this.clear(); })
              .layoutWeight(1)
              .margin({ right: 12 })
            Button('Confirm')
              .height(44)
              .fontSize(15)
              .backgroundColor('#233A6B')
              .fontColor('#fff')
              .borderRadius(22)
              .onClick(() => { this.confirm && this.confirm(); })
              .layoutWeight(1)
          }
        }
        .width('70%')
        .height('100%')
        .padding(20)
        .backgroundColor('#FFFFFF')
        .shadow({ color: '#00000022', radius: 8, offsetX: -2, offsetY: 0 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#00000055')
    }
  }
}