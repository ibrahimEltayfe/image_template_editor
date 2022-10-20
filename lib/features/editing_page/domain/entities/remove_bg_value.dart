import 'package:equatable/equatable.dart';

class RemoveBGValues extends Equatable{
  final int red;
  final int green;
  final int blue;
  final int feather;

  const RemoveBGValues({required this.red,required this.green,required this.blue,required this.feather});

  copyWith({
    int? red,
    int? green,
    int? blue,
    int? feather,
  }){
    return RemoveBGValues(
        red:red??this.red,
        green: green??this.green,
        blue: blue ?? this.blue,
        feather: feather??this.feather,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [red,green,blue,feather];

}