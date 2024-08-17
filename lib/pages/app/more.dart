import 'package:flutter/material.dart';
import '../../data/data.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MorePage extends StatefulWidget {
  final int index;
  final String store;

  const MorePage({
    super.key, 
    required this.index,
    required this.store,
    });

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  final List<Market> markets = marketList;
  String currentStore = '';
  int index = 0;
  List<dynamic> specStore = [];
  bool isLoading = true;
  

  @override
  void initState() {
    super.initState();
    index = index;
    currentStore = widget.store;
    setState(() {
      specStore = markets.where((market) => market.description == currentStore).toList();
      
    });
    isLoading = false;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentStore),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: isLoading
              ? LoadingAnimationWidget.halfTriangleDot(
                  color: Color.fromARGB(255, 109, 121, 109),
                  size: 50,
                )
              : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 30,
              ),
              itemCount: specStore.length,
              itemBuilder: (context, index) {
                final market = specStore[index];
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.8),
                            offset: Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ],
                        image: DecorationImage(
                          image: AssetImage(market.imgPath),
                          fit: BoxFit.cover,
                        ),
                      ),
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                );
              },
            ),
        ),
      ),
    );
  }
}