import loading1 from '../../pages/loadingComponent_part1';

@CustomDialog
export struct loading{
  controller: CustomDialogController;
  build() {
    Column() {
      loading1()
    }
    .width('40vp')
    .height('40vp')
    .backgroundColor(Color.White)
  }
}