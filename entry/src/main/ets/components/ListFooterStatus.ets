@Component
export struct ListFooterStatus {
  @Prop loadingMore: boolean = false;
  @Prop noMore: boolean = false;
  @Prop dataCount: number = 0;
  @Prop refreshing: boolean = false;

  build() {
    ListItem() {
      if (this.loadingMore) {
        Row() {
          LoadingProgress()
            .width(30)
            .height(30)
          Text(' 正在加载...')
            .fontSize(14)
            .margin({ left: 6 })
        }.width('100%').justifyContent(FlexAlign.Center).padding(20)
      } else if (this.noMore && this.dataCount > 0) {
        Text('—— 没有更多数据 ——')
          .fontSize(12)
          .fontColor('#999')
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding(20)
      } else if (this.dataCount === 0 && !this.refreshing) {
        Text('暂无数据')
          .fontSize(14)
          .fontColor('#999')
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding(40)
      }
    }
  }
}