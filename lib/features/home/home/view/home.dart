import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_manipulate/core/constants/app_colors.dart';
import 'package:image_manipulate/core/constants/app_strings.dart';
import 'package:image_manipulate/core/constants/app_styles.dart';
import 'package:image_manipulate/core/extensions/size_config.dart';
import 'package:image_manipulate/core/utils/injector.dart' as di;
import 'package:image_manipulate/features/editing_page/presentation/editing_page/view/editing_view.dart';
import '../view_model/home_viewmodel.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final HomeViewModel homeViewModel = HomeViewModel(di.injector());

  @override
  void initState() {
    homeViewModel.start(null);
    homeViewModel.imageOutputViewModel.listen((event) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => EditingPage(image:event)
        ));
    },onError: (e){
      Fluttertoast.showToast(msg: e.toString());
    });
    super.initState();
  }

  @override
  void dispose() {
    homeViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const _AppBar(),
      floatingActionButton: _FloatingActionButton(
        onPressed: ()async{
        await homeViewModel.pickGalleryImage();
      },),

      body: Container(
          width: context.width,
          height: context.height - context.topPadding,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: context.width*0.1),

          child: AutoSizeText(
            AppStrings.importPhotoToStartEditing,
            style: getBoldTextStyle(fontSize: 30,color: AppColors.grey),
            maxLines: 2,
            textAlign: TextAlign.center,
          )
      )

    );
  }
}

class _AppBar extends StatelessWidget with PreferredSizeWidget{
  const _AppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(AppStrings.appName,style: getBoldTextStyle(fontSize: 24),),
      centerTitle: true,
      backgroundColor: AppColors.white,
      elevation: 2,

    );
  }
}

class _FloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _FloatingActionButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        mini: false,
        onPressed: onPressed,
        child: LayoutBuilder(
          builder: (_, constraints) {
            return SizedBox(
              width: constraints.maxWidth*0.8,
              height: constraints.maxHeight*0.8,
              child: const FittedBox(
                  child: Icon(Icons.add,color: AppColors.white,)
              ),
            );
          },
        ),
    );
  }
}