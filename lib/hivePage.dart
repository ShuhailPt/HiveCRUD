
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HivePage extends StatefulWidget {
  HivePage({super.key});


  @override
  State<HivePage> createState() => _HivePageState();
}

class _HivePageState extends State<HivePage> {
  final TextEditingController nameController=TextEditingController();
  final TextEditingController qntyController=TextEditingController();

  List<Map<String,dynamic>> items=[];
  final shoppingBox =Hive.box("RBox");

  void initState(){
    super.initState();
    refreshItem();
  }

  void refreshItem(){
    final data = shoppingBox.keys.map((key){
      final item= shoppingBox.get(key);
      return {
        "key":key,
        "Name":item["Name"],
        "Quantity":item["Quantity"]
      };
    }).toList();
    setState(() {
      items= data.reversed.toList();
    });
  }



  //create Map

  Future<void> createItem(Map<String,dynamic> newItem) async{
    await shoppingBox.add(newItem);
    refreshItem();
    print("amount of dat is ${shoppingBox.length}");
  }

  //update
  Future<void> updateItem(int itemKey,Map<String,dynamic>item)async {
    await
    shoppingBox.put(itemKey, item);
    refreshItem();
  }
  //delete
  Future<void> deleteItem(int itemKey)async {
    await shoppingBox.delete(itemKey);
    refreshItem();

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content:Text("deleted...."))
    );
  }



  void showForm(BuildContext ctx,int? itemKey) async{
    if (itemKey!=null){
      final existingItem=
          items.firstWhere((element) => element["key"]==itemKey);
      nameController.text=existingItem["Name"];
      qntyController.text=existingItem["Quantity"];
    }
    showModalBottomSheet(
        context: ctx,
        elevation: 5,
        isScrollControlled: true,
        builder: (_)=>
            Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  top: 15,
                  left: 15,
                  right: 15
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end ,
                children: [
                  TextField(
                    controller:nameController ,
                    decoration: InputDecoration(hintText: "Name"),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    controller:qntyController ,
                    decoration: InputDecoration(hintText: "Quantity"),
                  ),
                  SizedBox(height: 20,),
                  ElevatedButton(onPressed: (){
                    if(itemKey==null){
                      createItem({
                        "Name":nameController.text,
                        "Quantity":qntyController.text,

                      });
                    }
                    if(itemKey!=null){
                      updateItem(itemKey,{
                        "Name":nameController.text.trim(),
                        "Quantity":qntyController.text.trim(),
                      });
                    }

                    nameController.text="";
                    qntyController.text="";
                    Navigator.of(ctx).pop();

                  }, child: Text(itemKey==null?"Create New":"Update"))
                ],

              ),

            )
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Hive"),
      ),
      body: ListView.builder(
        itemCount: items.length,
          itemBuilder: (context,index){
          final currentItem=items[index];
            return Card(
              color: Colors.grey,
              margin: EdgeInsets.all(10),
              elevation: 3,
              child: ListTile(
                title: Text(currentItem["Name"]),
                subtitle: Text(currentItem["Quantity"].toString()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(onPressed: (){
                      showForm(context, currentItem["key"]);
                    }, icon: Icon(Icons.edit)),
                    IconButton(onPressed: (){
                      deleteItem(currentItem["key"]);

                    }, icon: Icon(Icons.delete)),

                  ],
                ),
              ),

            );


          }),



      floatingActionButton: FloatingActionButton(
         onPressed: ()  =>
             showForm(context,null),
        child: const Icon(Icons.add),
      ),

    );
  }
}



