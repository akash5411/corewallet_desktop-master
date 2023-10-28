import 'dart:math';
import 'package:corewallet_desktop/Values/appColors.dart';
import 'package:corewallet_desktop/Values/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'create_page_step3.dart';


class CreateWalletStep2 extends StatefulWidget {
  List seedPhare;
  bool isNew;
  CreateWalletStep2({Key? key,required this.isNew,required this.seedPhare}) : super(key: key);

  @override
  State<CreateWalletStep2> createState() => _CreateWalletStep2State();
}

class _CreateWalletStep2State extends State<CreateWalletStep2> {
  @override
  Widget build(BuildContext context) {

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return  Scaffold(
      bottomNavigationBar: IntrinsicHeight(
        child: InkWell(
          onTap: (){
            //old code
       /*     var seedPhase = widget.seedPhare;

            var random = Random();
            List randomFive = [];
            for(int i=0;randomFive.length < 5 ;i++){

              int index = random.nextInt(seedPhase.length);
              String element = seedPhase[index];

              var test = {
                "id": index + 1,
                "name": element
              };


              int a = randomFive.indexWhere((element) => element['id'] == test['id']);
              if(a != -1){
                //print(randomFive.toString());
              }
              else{
                randomFive.add(test);
              }
            }*/

            //print(randomFive);

            Navigator.pop(context);

            //old code
       /*     Navigator.push(context, MaterialPageRoute(builder: (context) => CreateWalletStep3(
                seedPhase: randomFive,
                isNew:widget.isNew
            )));*/
            Navigator.push(context, MaterialPageRoute(builder: (context) => CreateWalletStep3(
                seedPhase: widget.seedPhare,
                isNew:widget.isNew
            )));

          },
          child: Center(
            child: Container(
              height: 50,
              margin: const EdgeInsets.fromLTRB(20,0,20,20),
              width: Responsive.isDesktop(context) ? width/2 : width,
              alignment: Alignment.center,
              decoration: BoxDecoration(

                  gradient: AppColors.buttonGradient2,
                  borderRadius: BorderRadius.circular(8)
              ),
              child: const Text(
                  "Continue",
                  style: TextStyle(
                      fontSize: 14,
                      color: AppColors.white ,
                      fontFamily: "Sf-SemiBold"
                  )
              ),

            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            //App Bar
            Row(
              children: [
                InkWell(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          border: Border.all(color:AppColors.greydark),
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              AppColors.greyColor2,
                              AppColors.BlackgroundBlue,

                            ],
                          )
                      ),
                      child: Center(
                        child:Image.asset("assets/icons/backarrow.png",height: 24),)),
                ),
                const SizedBox(width: 20),

                Text(
                    "Seed Phrase",
                    style: TextStyle(
                        color: AppColors.White,
                        fontFamily: "Sf-SemiBold",
                        fontSize: Responsive.isMobile(context)?18:20
                    )
                ),

              ],
            ),
            const SizedBox(height: 40),

            const Text(
                "Write Down Your Phrase",
                style: TextStyle(
                    color: AppColors.White,
                    fontFamily: "Sf-SemiBold",
                    fontSize: 18
                )
            ),
            const SizedBox(height: 10),


            Text(
                "This is your seed phrase. Write it down on a piece of paper and keep it in a safe place.\nYou’ll be asked to re-enter this phrase (in order) on the next step",
                style: TextStyle(
                    color: AppColors.white.withOpacity(0.5),
                    fontFamily: "Sf-SemiBold",
                    fontSize: 12
                )
            ),


            const SizedBox(height: 40),

            NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overScroll) {
                overScroll.disallowIndicator();

                return false;
              },
              child: AlignedGridView.count(
                scrollDirection: Axis.vertical,
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                itemCount: widget.seedPhare.length,
                itemBuilder: (BuildContext context, int index) {
                  var list =  widget.seedPhare[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.border253A66)
                    ),
                    child:Center(
                      child: Text(
                        "${index+1}. $list",
                        style: const TextStyle(
                            color: AppColors.White,
                            fontFamily: "Sf-Regular",
                            fontSize: 14
                        ),
                      ),
                    ),
                  );

                },

              ),
            ),
          ],
        ),
      ),
    );
  }
}
