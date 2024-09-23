import { GeneratedTypeLiteralInterface_2Imp } from '../../pages/IndexPhone'

interface HistoryRecordInterface {
  description: string;
  url: string;
  device: string;
  deviceCode: string;
  updateTime: string;
}

interface DetectionItem {
  cls: string;
  box: number[];
  score: string;
}

@Component
@CustomDialog
export default struct ShowDialog {
  controller: CustomDialogController;
  @Link selectedItem: HistoryRecordInterface | null;
  data: GeneratedTypeLiteralInterface_2Imp | null = null;

  aboutToAppear(): void {
    if (this.selectedItem) {
      this.data = JSON.parse(this.selectedItem.description) as GeneratedTypeLiteralInterface_2Imp;
    }
  }

  build() {
    if (this.selectedItem) {  // 确保 selectedItem 存在
      Column() {
        Row() {
          Image($r('app.media.return'))
            .onClick(() => {
              this.controller.close();
            }).margin({right:220}).height(27);
          Text('详细信息')
            .fontSize(20)
            .fontWeight(FontWeight.Bold);
        }.margin({right:230,top:15})
        Image(this.selectedItem.url).width('50%').height('Contain')
          .margin({ top: 10, bottom: 10 });
        Divider().margin({ top: 2, bottom: 9 }).color(Color.Black).height(7);
        Column() {
          Row() {
            Text('时间:')
              .fontSize(23)  // 标题字体稍微大一点
              .fontWeight(FontWeight.Bold)
              .width('14%').margin({left:34})  // 设置宽度，调整为合适的百分比
              .height(23);  // 设置高度

            Text(this.selectedItem.updateTime)
              .fontSize(22)
              .margin({ top: 5, bottom: 5 })
              .width('67%')  // 设置宽度，调整为合适的百分比
              .height(23);  // 设置高度
          }

          // 设备标题和内容
          Row() {
            Text('设备:')
              .fontSize(23)  // 标题字体稍微大一点
              .fontWeight(FontWeight.Bold)
              .width('14%').margin({left:34})  // 设置宽度，调整为合适的百分比
              .height(23);  // 设置高度

            Text(this.selectedItem.device)
              .fontSize(22)
              .margin({ top: 5, bottom: 5 })
              .width('67%')  // 设置宽度，调整为合适的百分比
              .height(23);  // 设置高度
          }

          // 设备码
          Row() {
            Text('编码:')
              .fontSize(23)  // 标题字体稍微大一点
              .fontWeight(FontWeight.Bold)
              .width('14%').margin({left:34})  // 设置宽度，调整为合适的百分比
              .height(23);  // 设置高度

            Text(this.selectedItem.deviceCode)
              .fontSize(22)
              .margin({ top: 9, bottom: 5 })
              .width('67%')  // 设置宽度，调整为合适的百分比
              .height(23);  // 设置高度
          }

          // 描述标题和内容
          Row() {
            Text('描述:')
              .fontSize(23)  // 标题字体稍微大一点
              .fontWeight(FontWeight.Bold)
              .margin({ top: 7, bottom: 5, right: 7 ,left:54})
              .width('14%')  // 设置宽度，调整为合适的百分比
              .height(23);  // 设置高度

            // 数据列表
            if (this.data) {
              if (this.data.detection_classes && this.data.detection_boxes && this.data.detection_scores) {
                List() {
                  // 表头
                  ListItem() {
                    Row() {
                      Text('     Class')
                        .width(160)
                        .fontWeight('bold');
                      Text('            Box')
                        .width(220)
                        .fontWeight('bold');
                      Text(' Score')
                        .width(160)
                        .fontWeight('bold');
                    }
                    .padding(2)
                    .margin({top:20})
                    .border({ width: 0, color: Color.White }); // 设置背景颜色以区分表头
                  }

                  // 表体
                  ForEach(this.data.detection_classes.map((cls, index) => {
                    const item: DetectionItem = {
                      cls,
                      box: (this.data?.detection_boxes && index < (this.data.detection_boxes?.length ?? 0))
                        ? this.data.detection_boxes[index]
                        : [],
                      score: (this.data?.detection_scores && index < (this.data.detection_scores?.length ?? 0))
                        ? this.data.detection_scores[index].toFixed(2)
                        : '',
                    };
                    return item;
                  }), (item: DetectionItem) => {
                    ListItem() {
                      Row() {
                        Text(item.cls || '')
                          .fontSize(15)
                          .width(160)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                          .maxLines(1);
                        Text(item.box.length > 0 ? `(${item.box.join(', ')})` : '')
                          .fontSize(15)
                          .width(220)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                          .maxLines(1);
                        Text(item.score)
                          .fontSize(15)
                          .width(160)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                          .maxLines(1).margin({left:10});
                      }
                      .padding(2)
                      .border({ width: 0, color: Color.White })
                      .borderRadius('12vp')
                      .height(25)
                      .margin({ bottom: 2 });
                    }
                  });
                }.scrollBar(BarState.Auto).width("70%").height("30%").margin({right:50})
              }
            }
          }
          .padding({ left: 25 })
        }

        // Divider().margin({ top: 9, bottom: 17 }).color(Color.White);
      }
      .borderRadius(14)
      .width('60%')
      .height('95%')
      .opacity(0.95)
      .backgroundColor(Color.White); // 这里需要一个闭合的括号
    }
  }
}
