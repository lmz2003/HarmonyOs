//loadingComponent_part1.ets
@Component
export default struct loadingComponent_part1 {
  private imageWidth: number | Resource = 0
  private imageHeight: number | Resource = 0
  build() {
    Column() {
      ImageAnimator()
        .images([
          {
            src: $r("app.media.loading07"),
            duration: 200, //每一帧图片的播放时长，单位毫秒
          },
          {
            src: $r("app.media.loading08"),
            duration: 200,
          },
          {
            src: $r("app.media.loading09"),
            duration: 200,
          },
          {
            src: $r("app.media.loading10"),
            duration: 200,
          },
          {
            src: $r("app.media.loading11"),
            duration: 200,
          },
          {
            src: $r("app.media.loading12"),
            duration: 200,
          }])
        .width("40vp")
        .height("40vp")
        .iterations(-1)
          //	设置播放顺序。false表示从第1张图片播放到最后1张图片； true表示从最后1张图片播放到第1张图片。
        .fixedSize(true)
          //设置图片大小是否固定为组件大小。 true表示图片大小与组件大小一致，此时设置图片的width 、height 、top 和left属性是无效的。false表示每一张图片的width 、height 、top和left属性都要单独设置。
        .reverse(true)
          //设置播放顺序。false表示从第1张图片播放到最后1张图片； true表示从最后1张图片播放到第1张图片。
        .fillMode(FillMode.None)
          //设置动画开始前和结束后的状态，可选值参见FillMode说明
        .state(AnimationStatus.Running)
      //Running表示动画处于播放状态
    }
  }
}
