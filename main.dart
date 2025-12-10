import 'package:flutter/material.dart';

// Simple single-file Flutter food ordering demo app
// How to use: create a new Flutter project and replace lib/main.dart with this file.
// No external packages required.

void main() {
  runApp(FoodOrderApp());
}

class FoodOrderApp extends StatefulWidget {
  @override
  _FoodOrderAppState createState() => _FoodOrderAppState();
}

class _FoodOrderAppState extends State<FoodOrderApp> {
  bool _dark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodOrder Demo',
      theme: _dark ? ThemeData.dark() : ThemeData.light().copyWith(
        primaryColor: Colors.deepOrange,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepOrange),
      ),
      home: HomePage(onToggleTheme: () {
        setState(() => _dark = !_dark);
      }),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- Simple in-memory data models ---
class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  MenuItem({required this.id, required this.name, required this.description, required this.price, required this.imageUrl});
}

class CartItem {
  final MenuItem item;
  int qty;
  CartItem({required this.item, this.qty = 1});
}

// Global in-memory cart using ValueNotifier so UI can listen
class Cart {
  Cart._();
  static final Cart instance = Cart._();
  final ValueNotifier<List<CartItem>> items = ValueNotifier([]);

  void add(MenuItem m) {
    final list = items.value;
    final index = list.indexWhere((c) => c.item.id == m.id);
    if (index >= 0) {
      list[index].qty += 1;
    } else {
      list.add(CartItem(item: m));
    }
    items.value = List.from(list);
  }

  void remove(MenuItem m) {
    final list = items.value;
    final index = list.indexWhere((c) => c.item.id == m.id);
    if (index >= 0) {
      list.removeAt(index);
    }
    items.value = List.from(list);
  }

  void changeQty(MenuItem m, int qty) {
    final list = items.value;
    final index = list.indexWhere((c) => c.item.id == m.id);
    if (index >= 0) {
      if (qty <= 0) list.removeAt(index);
      else list[index].qty = qty;
    }
    items.value = List.from(list);
  }

  double get total => items.value.fold(0.0, (t, c) => t + c.qty * c.item.price);

  void clear() {
    items.value = [];
  }
}

// Sample menu
final List<MenuItem> sampleMenu = [
  MenuItem(
    id: 'm1',
    name: 'ข้าวผัดหมู',
    description: 'ข้าวผัดสูตรต้นตำรับ ใส่ผักและไข่',
    price: 65.0,
    imageUrl: 'https://images.unsplash.com/photo-1604908554022-9f0b2d3c6f71?auto=format&fit=crop&w=800&q=60',
  ),
  MenuItem(
    id: 'm2',
    name: 'ผัดกะเพราไก่',
    description: 'รสจัดจ้าน เสิร์ฟพร้อมไข่ดาว',
    price: 70.0,
    imageUrl: 'https://images.unsplash.com/photo-1604908177522-1f7d6d0b9f3a?auto=format&fit=crop&w=800&q=60',
  ),
  MenuItem(
    id: 'm3',
    name: 'ต้มยำกุ้ง',
    description: 'น้ำต้มยำรสเปรี้ยว-เผ็ด ต้มกับเห็ดและกุ้งสด',
    price: 120.0,
    imageUrl: 'https://images.unsplash.com/photo-1543352634-1b2d4a2b3c32?auto=format&fit=crop&w=800&q=60',
  ),
  MenuItem(
    id: 'm4',
    name: 'ส้มตำไทย',
    description: 'ส้มตำไทยรสหวาน เค็ม เปรี้ยว ครบรส',
    price: 50.0,
    imageUrl: 'https://images.unsplash.com/photo-1604908177523-a9d6f3f9a9b4?auto=format&fit=crop&w=800&q=60',
  ),
];

// --- UI ---
class HomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  HomePage({required this.onToggleTheme});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [MenuScreen(), CartScreen()];
    return Scaffold(
      appBar: AppBar(
        title: Text('สั่งอาหาร (Demo)'),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle theme',
          ),
          ValueListenableBuilder<List<CartItem>>(
            valueListenable: Cart.instance.items,
            builder: (_, list, __) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: () => setState(() => _selectedIndex = 1),
                ),
                if (list.isNotEmpty)
                  Positioned(
                    right: 6,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text('${list.fold<int>(0, (s, c) => s + c.qty)}', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  )
              ],
            ),
          )
        ],
      ),
      body: tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'เมนู'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'ตะกร้า'),
        ],
      ),
    );
  }
}

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: sampleMenu.length,
      itemBuilder: (_, i) {
        final m = sampleMenu[i];
        return MenuCard(menu: m);
      },
    );
  }
}

class MenuCard extends StatelessWidget {
  final MenuItem menu;
  MenuCard({required this.menu});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
            child: Image.network(menu.imageUrl, width: 110, height: 110, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width:110,height:110,color:Colors.grey,child:Icon(Icons.fastfood))),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(menu.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text(menu.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${menu.price.toStringAsFixed(0)} ฿', style: TextStyle(fontSize: 16, color: Colors.black87)),
                      ElevatedButton.icon(
                        onPressed: () {
                          Cart.instance.add(menu);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เพิ่ม ${menu.name} ลงตะกร้า')));
                        },
                        icon: Icon(Icons.add_shopping_cart),
                        label: Text('เพิ่ม'),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<CartItem>>(
      valueListenable: Cart.instance.items,
      builder: (_, list, __) {
        if (list.isEmpty) return Center(child: Text('ตะกร้าว่างเปล่า'));
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final c = list[i];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Image.network(c.item.imageUrl, width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.fastfood)),
                      title: Text(c.item.name),
                      subtitle: Text('${c.item.price.toStringAsFixed(0)} ฿ x ${c.qty}'),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(icon: Icon(Icons.remove_circle_outline), onPressed: () => Cart.instance.changeQty(c.item, c.qty - 1)),
                        Text('${c.qty}'),
                        IconButton(icon: Icon(Icons.add_circle_outline), onPressed: () => Cart.instance.changeQty(c.item, c.qty + 1)),
                      ]),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('รวม: ${Cart.instance.total.toStringAsFixed(0)} ฿', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final ok = await showDialog<bool>(context: context, builder: (_) => ConfirmOrderDialog(total: Cart.instance.total));
                      if (ok == true) {
                        // Simulate placing order
                        await Future.delayed(Duration(milliseconds: 700));
                        Cart.instance.clear();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('สั่งเรียบร้อย!')));
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('สั่งอาหาร', style: TextStyle(fontSize: 16)),
                    ),
                  )
                ],
              ),
            )
          ],
        );
      },
    );
  }
}

class ConfirmOrderDialog extends StatelessWidget {
  final double total;
  ConfirmOrderDialog({required this.total});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('ยืนยันการสั่ง'),
      content: Text('รวมทั้งสิ้น ${total.toStringAsFixed(0)} ฿\nต้องการยืนยันการสั่งหรือไม่?'),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('ยกเลิก')),
        ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text('ยืนยัน'))
      ],
    );
  }
}
