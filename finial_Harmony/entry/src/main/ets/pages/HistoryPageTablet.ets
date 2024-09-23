import router from '@ohos.router';
import Dialog from '@ohos.arkui.advanced.Dialog';
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import ShowDialogTablet from '../components/Dialog/ShowDialogTablet';

// 定义历史记录项的接口
interface HistoryRecord {
  id:number;
  description: string;
  url: string;
  device: string;
  deviceCode:string;
  updateTime: string;
  deviceOpacity?: number; // 可选的透明度属性
  timeOpacity?: number;   // 可选的透明度属性
  buttonOpacity?: number; // 可选的透明度属性
}

interface Row {
  id: number;
  description: string;
  url: string;
  device: string;
  deviceCode:string;
  createTime: string;
  updateTime: string;
}

interface ApiData {
  total: number;
  rows: Row[];
}

interface ApiResponse {
  code: number;
  msg: string;
  data: ApiData;
}



@Entry
@Component
struct HistoryPage {
  @State historyData: HistoryRecord[] = [];
  @State selectedItem: HistoryRecord | null = null;

  dialogShowController: CustomDialogController | null = new CustomDialogController({
    builder: ShowDialogTablet({
      selectedItem: this.selectedItem, // 将选中的数据传递给弹窗组件
    }),
    alignment: DialogAlignment.Center, // 弹窗居中显示
    customStyle: true, // 使用自定义样式
  });


  //获取历史数据的方法
  async fetchHistoryData(): Promise<void> {
    return new Promise((resolve, reject) => {
      // 创建HTTP请求实例
      let httpRequest = http.createHttp();

      // 订阅HTTP响应头
      httpRequest.on('headersReceive', (header) => {
        console.info('header: ' + JSON.stringify(header));
      });

      // 发送HTTP请求
      httpRequest.request(
        // "http://ngrok.ss5.tunnelfrp.com/har", // 替换为你的后端API地址
        // "http://ngroktwo.sa1.tunnelfrp.com/har",
        // "http://ngrokthree.sv6.tunnelfrp.com/har",
        `http://ngrokthree.sv6.tunnelfrp.com/har`,//注意，有可能必须得是反引号！！！
        {
          method: http.RequestMethod.GET, // 假设获取历史记录用的是GET请求
          header: {
            'Content-Type': 'application/json',
            // 'Authorization': 'Bearer your_token', // 如果需要的话，添加授权token
          },
          expectDataType: http.HttpDataType.STRING, // 期望返回数据类型为STRING
          usingCache: true,
          connectTimeout: 60000,
          readTimeout: 60000,
        },
        (err: BusinessError, data: http.HttpResponse) => {
          if (!err) {
            // 成功获取数据，解析返回的JSON字符串为HistoryRecord数组
            if (typeof data.result === 'string') {
              try {
                const parsedData: ApiResponse = JSON.parse(data.result);
                if (parsedData.code === 1 && parsedData.data && parsedData.data.rows) {
                  // 提取 rows 并映射到 HistoryRecord 数组中
                  this.historyData = parsedData.data.rows.map((item): HistoryRecord => ({
                    id:item.id,
                    description: item.description,
                    url: item.url,
                    device: item.device,
                    deviceCode:item.deviceCode,
                    updateTime: item.updateTime,
                  }));

                  console.log("Parsed history data:", this.historyData);
                  resolve(); // 数据获取成功，resolve Promise
                } else {
                  console.error('Unexpected API response format:', parsedData);
                  reject('Unexpected API response format');
                }
              } catch (error) {
                console.error('Error parsing history data:', error);
                reject(error);
              }
            } else {
              console.error('Unexpected data type:', typeof data.result);
              reject('Unexpected data type');
            }
            console.info('Result:' + JSON.stringify(data.result));
            console.info('code:' + JSON.stringify(data.responseCode));
          } else {
            console.error('error:' + JSON.stringify(err));
            reject(err);
          }

          // 销毁请求和取消订阅
          httpRequest.off('headersReceive');
          httpRequest.destroy();
        }
      );
    });
  }

  aboutToAppear(): void {
    this.fetchHistoryData();
  }


  @Builder itemEnd(item: HistoryRecord, index: number) {
    Column() {
      Button("删除").margin("4vp").onClick(() => {
        this.deleteRecord(index, item.id); // 在删除按钮上添加点击事件
      });
      // Text('设备: ' + item.device).fontSize(14).margin({ top: 10 });
      // Text('更新时间: ' + item.updateTime).fontSize(14).margin({ top: 5 });
    }.padding("4vp").justifyContent(FlexAlign.SpaceEvenly);
  }

  build() {
    Column() {
      Row(){
        Image($r('app.media.return')).onClick(() => {
          router.back(); // 返回到前一个页面
        }).margin({right:446}).height(27);
        Text('历史记录').fontSize(20).fontWeight(FontWeight.Bold).margin({left:36});
      }.justifyContent(FlexAlign.Start).margin({right:575})
      if (this.historyData.length === 0) {
        Text('暂无历史记录').fontSize(16).margin({ top: 245, bottom: 10 });
      } else {
        List() {
          // 表头
          ListItem() {
            Row() {
              // Text('Description').width(245).fontSize(18);//150
              Text('URL').width(305).fontSize(18);//250
              Text('device').width(220).fontSize(18);
              Text('deviceCode').width(280).fontSize(18);
              Text('time').width(250).fontSize(18);
            }
            .padding(10)
            .border({ width: 1, color: '#ccc' })
            .margin({ bottom: 10,top:40 })
            .borderColor(Color.White);
          }

          // 表体
          ForEach(this.historyData, (item: HistoryRecord, index: number) => {
            ListItem() {
              Row() {
                // Text(item.description)
                //   .fontSize(14)
                //   .width(245)
                //   .textOverflow({ overflow: TextOverflow.Ellipsis })
                //   .maxLines(1);
                Text(item.url).fontSize(17).width(305).textOverflow({ overflow: TextOverflow.Ellipsis }).maxLines(1);
                Text(item.device).fontSize(17).width(220).textOverflow({ overflow: TextOverflow.Ellipsis }).maxLines(1);
                Text(item.deviceCode).fontSize(17).width(280).textOverflow({ overflow: TextOverflow.Ellipsis }).maxLines(1);
                Text(item.updateTime).fontSize(17).width(250);
              }
              .padding(10)
              .border({ width: 1, color: '#ccc' })
              .borderRadius('12vp')
              .height(55)
              .margin({ bottom: 10 })
              .onClick(() => {
                this.showDetailDialog(item); // 点击行时显示详细信息
              });
            }
            .swipeAction({
              end: {
                builder: () => {
                  this.itemEnd(item, index)
                },
                onAction: () => {
                  // 当删除按钮被点击时，执行删除操作
                },
                actionAreaDistance: 120, // 增加滑动距离，以显示更多信息
              }
            });
          });
        }
        .listDirection(Axis.Vertical) // 排列方向
        .scrollBar(BarState.Auto)
        .scrollBarColor('#808080')
        .scrollBarWidth(4)
        .friction(0.9)
        .width('100%')
        .height('80%');
      }
    }.width('100%').padding(20);

  }

  deleteRecord(index: number, id: number) {
    this.historyData.splice(index, 1);

    // 创建HTTP请求任务
    let httpRequest = http.createHttp();
    httpRequest.request(
      `http://ngrokthree.sv6.tunnelfrp.com/har/${id}`, // 替换为你的API端点   注意是反引号！！！！！
      {
        method: http.RequestMethod.DELETE, // 使用DELETE方法
        header: {
          'Content-Type': 'application/json'
        }
      }, (err: BusinessError, data: http.HttpResponse) => {
      if (!err) {
        console.info('删除成功: ' + JSON.stringify(data.result));
      } else {
        console.error('删除失败: ' + JSON.stringify(err));
      }
      // 销毁HTTP请求任务
      httpRequest.destroy();
    });
  }
  showDetailDialog(item: HistoryRecord) {
    // 创建并显示详细信息的弹窗
    this.selectedItem = item; // 设置选中的数据
    this.dialogShowController?.open(); // 打开弹窗
  }

}




