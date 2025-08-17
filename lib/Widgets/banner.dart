import 'package:ecom/core/Common/Utils/colors.dart';
import 'package:ecom/view/role_based_login/User/User%20Activity/Add%20to%20Cart/Screen/cart_screen.dart';
import 'package:flutter/material.dart';

class MyBanner extends StatelessWidget {
  const MyBanner({super.key});

  @override
  Widget build(BuildContext context) {
   Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height*0.23,
      width: size.width,
      color: bannerColor,
      child: Padding(
        padding: EdgeInsets.only(left: 27),
        child: Stack(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "NEW COLLECTIONS",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -2,
                  ),
                  ),
                  Row(
                    children: [
                      Text( 
                        "20",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -3,
                        ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text( "%",
                              style: TextStyle(
                               fontWeight: FontWeight.w900,
                                
                              ),
                            ),
                            Text("OFF",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1.5,
                                height: 0.6,
                              ),
                            ),
                            
                          ]
                         
                        )
                    ],
                  ),
                  MaterialButton(
                    onPressed: () {
                     
                     Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                  
                    },
                    color: Colors.black,
                    child: Text(
                      "SHOP NOW",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        ),
                    ),
                  ),

            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Image.asset(
              "assets/images/banner1.png",
              height: size.height*0.19,
              
            ),
          ),
        ],),
      ),
    );
  }
}