// ─────────────────────────────────────────────────────
// lib/core/data/app_database.dart
//
// FAKE DATABASE — no Firebase, no backend.
// All data lives here. Screens read from and write to
// this single file. Replace with Firebase later by
// swapping only this file.
// ─────────────────────────────────────────────────────

// ══════════════════════════════════════════════════════
// 1. USER MODEL
// ══════════════════════════════════════════════════════
class AppUser {
  final String id;
  String name;
  String email;
  String phone;
  String dob;
  String photoPath; // asset or network url
  int beans;        // loyalty points (max 2000 = free drink)
  String branchId;  // selected Barista's branch

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.dob,
    this.photoPath = 'assets/images/pic.png',
    this.beans = 0,
    this.branchId = '',
  });
}

// ══════════════════════════════════════════════════════
// 2. BRANCH MODEL
// ══════════════════════════════════════════════════════
class Branch {
  final String id;
  final String name;
  final String address;
  final String plusCode;
  final double lat;
  final double lng;
  // Can be:
  //   '' (empty)         → shows placeholder icon
  //   'assets/...'       → local asset image
  //   'https://...'      → network image
  final String image;

  const Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.plusCode,
    required this.lat,
    required this.lng,
    this.image = '',
  });
}

// ══════════════════════════════════════════════════════
// 3. PRODUCT MODEL
// ══════════════════════════════════════════════════════
class Product {
  final String id;
  final String name;
  final String category;   // 'drink' | 'food'
  final double price;      // in DT
  final String image;      // asset path
  final bool isBestSeller;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    this.isBestSeller = false,
  });

  // Format price as "11,500" (Tunisian format)
  String get formattedPrice =>
      price.toStringAsFixed(3).replaceAll('.', ',');
}

// ══════════════════════════════════════════════════════
// 4. ORDER MODEL
// ══════════════════════════════════════════════════════
enum OrderStatus { active, completed, cancelled }

class OrderItem {
  final Product product;
  int quantity;

  OrderItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

class AppOrder {
  final String id;
  final String userId;
  final String branchId;
  final List<OrderItem> items;
  final DateTime date;
  OrderStatus status;
  String? cancelReason;
  int? rating;
  String? review;

  AppOrder({
    required this.id,
    required this.userId,
    required this.branchId,
    required this.items,
    required this.date,
    this.status = OrderStatus.active,
    this.cancelReason,
    this.rating,
    this.review,
  });

  double get total =>
      items.fold(0, (sum, item) => sum + item.subtotal);

  String get formattedTotal =>
      '${total.toStringAsFixed(3).replaceAll('.', ',')} DT';
}

// ══════════════════════════════════════════════════════
// 5. CART
// ══════════════════════════════════════════════════════
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;

  String get formattedSubtotal =>
      '${subtotal.toStringAsFixed(3).replaceAll('.', ',')} DT';
}

// ══════════════════════════════════════════════════════
// 6. SIP & SHARE POST MODEL
// ══════════════════════════════════════════════════════
class SipSharePost {
  final String id;
  final String userName;
  final String avatarPath;
  final String caption;
  final String hashtag;
  final String postImagePath;

  const SipSharePost({
    required this.id,
    required this.userName,
    required this.avatarPath,
    required this.caption,
    required this.hashtag,
    required this.postImagePath,
  });
}

// ══════════════════════════════════════════════════════
// 7. APP STATE
// ══════════════════════════════════════════════════════
class AppDB {

  // ── Current logged-in user ──────────────────────────
  static AppUser currentUser = AppUser(
    id: 'user_001',
    name: 'Lina Bakkar',
    email: 'linabakkar22@gmail.com',
    phone: '+216 55 147 369',
    dob: '09 / 10 / 1991',
    photoPath: 'assets/images/pic.png',
    beans: 0,
    branchId: '',
  );

  // ── Selected branch (set on FindBaristaScreen) ──────
  static Branch? selectedBranch;

  // ── Cart ────────────────────────────────────────────
  static final List<CartItem> cart = [];

  // ── Orders history ──────────────────────────────────
  static final List<AppOrder> orders = [
    AppOrder(
      id: 'order_001',
      userId: 'user_001',
      branchId: 'branch_01',
      items: [OrderItem(product: _products[1], quantity: 1)],
      date: DateTime(2024, 11, 29, 13, 20),
      status: OrderStatus.active,
    ),
    AppOrder(
      id: 'order_002',
      userId: 'user_001',
      branchId: 'branch_01',
      items: [OrderItem(product: _products[0], quantity: 1)],
      date: DateTime(2024, 11, 10, 18, 5),
      status: OrderStatus.completed,
      rating: 5,
    ),
    AppOrder(
      id: 'order_003',
      userId: 'user_001',
      branchId: 'branch_01',
      items: [OrderItem(product: _products[2], quantity: 1)],
      date: DateTime(2024, 11, 10, 8, 30),
      status: OrderStatus.completed,
    ),
    AppOrder(
      id: 'order_004',
      userId: 'user_001',
      branchId: 'branch_01',
      items: [OrderItem(product: _products[3], quantity: 1)],
      date: DateTime(2024, 11, 2, 16, 0),
      status: OrderStatus.cancelled,
      cancelReason: 'I placed the order by mistake.',
    ),
  ];

  // ── Sip & Share posts ────────────────────────────────
  static const List<SipSharePost> sipSharePosts = [
    SipSharePost(
      id: 'post_001',
      userName: 'Med Amine Beji',
      avatarPath: 'assets/images/user1.png',
      caption: "today's coffee",
      hashtag: '#Macchiato_Nutella',
      postImagePath: 'assets/images/post1.png',
    ),
    SipSharePost(
      id: 'post_002',
      userName: 'Asma Chechia',
      avatarPath: 'assets/images/user2.png',
      caption: 'My go-to lunch',
      hashtag: '#Chicken Sandwich',
      postImagePath: 'assets/images/post2.png',
    ),
  ];

  // ── Registered users (fake auth) ────────────────────
  static final List<Map<String, String>> _registeredUsers = [
    {
      'email': 'linabakkar22@gmail.com',
      'password': '123456',
      'name': 'Lina Bakkar',
      'phone': '+216 55 147 369',
      'dob': '09 / 10 / 1991',
    },
  ];

  // ════════════════════════════════════════════════════
  // AUTH METHODS
  // ════════════════════════════════════════════════════

  static bool login(String email, String password) {
    final user = _registeredUsers.firstWhere(
      (u) =>
          u['email'] == email.trim() &&
          u['password'] == password.trim(),
      orElse: () => {},
    );
    if (user.isNotEmpty) {
      currentUser = AppUser(
        id: 'user_001',
        name: user['name']!,
        email: user['email']!,
        phone: user['phone']!,
        dob: user['dob']!,
      );
      return true;
    }
    return false;
  }

  static void register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String dob,
  }) {
    _registeredUsers.add({
      'email': email.trim(),
      'password': password.trim(),
      'name': name.trim(),
      'phone': phone.trim(),
      'dob': dob.trim(),
    });
    currentUser = AppUser(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      dob: dob.trim(),
    );
  }

  // ════════════════════════════════════════════════════
  // CART METHODS
  // ════════════════════════════════════════════════════

  static void addToCart(Product product) {
    final existing = cart.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );
    if (existing.quantity == 0) {
      cart.add(CartItem(product: product));
    } else {
      existing.quantity++;
    }
  }

  static void removeFromCart(String productId) {
    final index =
        cart.indexWhere((item) => item.product.id == productId);
    if (index == -1) return;
    if (cart[index].quantity > 1) {
      cart[index].quantity--;
    } else {
      cart.removeAt(index);
    }
  }

  static void clearCart() => cart.clear();

  static double get cartTotal =>
      cart.fold(0, (sum, item) => sum + item.subtotal);

  static String get cartTotalFormatted =>
      '${cartTotal.toStringAsFixed(3).replaceAll('.', ',')} DT';

  // ════════════════════════════════════════════════════
  // ORDER METHODS
  // ════════════════════════════════════════════════════

  static AppOrder placeOrder() {
    final order = AppOrder(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      userId: currentUser.id,
      branchId: selectedBranch?.id ?? '',
      items: List.from(cart.map(
          (c) => OrderItem(product: c.product, quantity: c.quantity))),
      date: DateTime.now(),
      status: OrderStatus.active,
    );
    orders.insert(0, order);
    clearCart();
    currentUser.beans = (currentUser.beans + 100).clamp(0, 2000);
    return order;
  }

  static void cancelOrder(String orderId, String reason) {
    final order = orders.firstWhere((o) => o.id == orderId);
    order.status = OrderStatus.cancelled;
    order.cancelReason = reason;
  }

  static void reviewOrder(String orderId, int rating, String review) {
    final order = orders.firstWhere((o) => o.id == orderId);
    order.rating = rating;
    order.review = review;
  }

  // ════════════════════════════════════════════════════
  // GETTERS
  // ════════════════════════════════════════════════════

  static List<AppOrder> get activeOrders =>
      orders.where((o) => o.status == OrderStatus.active).toList();

  static List<AppOrder> get completedOrders =>
      orders.where((o) => o.status == OrderStatus.completed).toList();

  static List<AppOrder> get cancelledOrders =>
      orders.where((o) => o.status == OrderStatus.cancelled).toList();
}

// ══════════════════════════════════════════════════════
// 8. STATIC DATA — branches & products
// ══════════════════════════════════════════════════════

// ── HOW TO ADD BRANCH PHOTOS ──────────────────────────
// Option A — local asset:
//   1. Put photo in assets/images/branches/branch_01.jpg
//   2. Set image: 'assets/images/branches/branch_01.jpg'
//
// Option B — network URL:
//   Set image: 'https://your-url.com/photo.jpg'
//
// Leave image: '' to show the placeholder icon.
// ─────────────────────────────────────────────────────

const List<Branch> kBranches = [
  Branch(
    id: 'branch_01',
    name: "Barista's Menzah 9",
    address: 'El Menzah',
    plusCode: 'R5X4+4G Tunis',
    lat: 36.8436, lng: 10.1935,
    image: 'assets/images/branches/branch_01.jpg',
  ),
  Branch(
    id: 'branch_02',
    name: "Barista's Menzah 6",
    address: 'El Menzah 6',
    plusCode: 'R5XC+97 Ariana',
    lat: 36.8502, lng: 10.1888,
    image: 'assets/images/branches/branch_02.jpg',
  ),
  Branch(
    id: 'branch_03',
    name: "Barista's Centre Urbain Nord",
    address: 'Centre Urbain Nord',
    plusCode: 'R5XW+397, Tunis',
    lat: 36.8611, lng: 10.1947,
    image: 'assets/images/branches/branch_03.jpg',
  ),
  Branch(
    id: 'branch_04',
    name: "Barista's Les Berges du Lac",
    address: 'Lac, Tunis',
    plusCode: 'R6MR+WG Tunis',
    lat: 36.8320, lng: 10.2283,
    image: 'assets/images/branches/branch_04.jpg',
  ),
  Branch(
    id: 'branch_05',
    name: "Barista's Staroil Mohamed 5",
    address: 'Ave Mohamed V',
    plusCode: 'R58M+3MQ, Tunis',
    lat: 36.8065, lng: 10.1815,
    image: 'assets/images/branches/branch_05.jpg',
  ),
  Branch(
    id: 'branch_06',
    name: "Barista's Ariana",
    address: 'Ariana',
    plusCode: 'V53P+PM Ariana',
    lat: 36.8625, lng: 10.1956,
    image: 'assets/images/branches/branch_06.jpg',
  ),
  Branch(
    id: 'branch_07',
    name: "Barista's La Marsa",
    address: 'La Marsa',
    plusCode: 'V8HM+P6G',
    lat: 36.8781, lng: 10.3247,
    image: 'assets/images/branches/branch_07.jpg',
  ),
  Branch(
    id: 'branch_08',
    name: "Barista's Les Jardins de Carthage",
    address: 'Tunis',
    plusCode: 'V75X+5R Tunis',
    lat: 36.8601, lng: 10.3198,
    image: 'assets/images/branches/branch_08.jpg',
  ),
  Branch(
    id: 'branch_09',
    name: "Barista's Lac 2",
    address: 'Avenue De La Bourse',
    plusCode: 'R7XC+89J, Tunis',
    lat: 36.8412, lng: 10.2401,
    image: 'assets/images/branches/branch_09.jpg',
  ),
  Branch(
    id: 'branch_10',
    name: "Barista's Sousse",
    address: 'Avenue Taieb Mhiri',
    plusCode: 'RJQG+XRX, Sousse',
    lat: 35.8256, lng: 10.6369,
    image: 'assets/images/branches/branch_10.jpg',
  ),
  Branch(
    id: 'branch_11',
    name: "Barista's Bardo",
    address: 'Tunis',
    plusCode: 'R47V+2Q Tunis',
    lat: 36.8094, lng: 10.1444,
    image: 'assets/images/branches/branch_11.jpg',
  ),
  Branch(
    id: 'branch_12',
    name: "Barista's Pathé Tunis City",
    address: 'Cebalat Ben Ammar',
    plusCode: 'V4XF+8W',
    lat: 36.9012, lng: 10.2156,
    image: 'assets/images/branches/branch_12.jpg',
  ),
  Branch(
    id: 'branch_13',
    name: "Barista's Pathé Azur City",
    address: 'Ben Arous',
    plusCode: 'P7G5+82',
    lat: 36.7312, lng: 10.2289,
    image: 'assets/images/branches/branch_13.jpg',
  ),
  Branch(
    id: 'branch_14',
    name: "Barista's Mall of Sfax",
    address: 'Route de Tunis Km 10',
    plusCode: 'Sakiet Ezzit',
    lat: 34.7893, lng: 10.7601,
    image: 'assets/images/branches/branch_14.jpg',
  ),
  Branch(
    id: 'branch_15',
    name: "Barista's L'Aouina",
    address: 'Tunis',
    plusCode: 'V754+697 Tunis',
    lat: 36.8512, lng: 10.2301,
    image: 'assets/images/branches/branch_15.jpg',
  ),
];

// ── Products ──────────────────────────────────────────
final List<Product> _products = [
  const Product(
    id: 'prod_01',
    name: 'Frappuccino Caramel',
    category: 'drink',
    price: 11.500,
    image: 'assets/images/frappuccino.png',
    isBestSeller: true,
  ),
  const Product(
    id: 'prod_02',
    name: 'Iced Macchiato Caramel',
    category: 'drink',
    price: 9.500,
    image: 'assets/images/iced_macchiato.png',
    isBestSeller: true,
  ),
  const Product(
    id: 'prod_03',
    name: 'Macchiato Caramel',
    category: 'drink',
    price: 8.500,
    image: 'assets/images/macchiato.png',
    isBestSeller: true,
  ),
  const Product(
    id: 'prod_04',
    name: 'Cachuète',
    category: 'food',
    price: 10.500,
    image: 'assets/images/cachuete.png',
    isBestSeller: true,
  ),
  const Product(
    id: 'prod_05',
    name: 'Mexican Salad',
    category: 'food',
    price: 10.000,
    image: 'assets/images/salade_cesar.png',
  ),
  const Product(
    id: 'prod_06',
    name: 'Frappuccino Praliné Pistache',
    category: 'drink',
    price: 15.500,
    image: 'assets/images/frappuccino.png',
  ),
  const Product(
    id: 'prod_07',
    name: 'Red Velvet',
    category: 'food',
    price: 10.500,
    image: 'assets/images/cachuete.png',
  ),
  const Product(
    id: 'prod_08',
    name: 'Strawberry Matcha',
    category: 'drink',
    price: 14.000,
    image: 'assets/images/macchiato.png',
  ),
];

// Public getters for screens
List<Product> get kProducts => _products;
List<Product> get kBestSellers =>
    _products.where((p) => p.isBestSeller).toList();

//  Mutable accessor used by FakePlatService to sync
// manager changes back into the client product list.
// Never use this directly in UI screens.
List<Product> get mutableProducts => _products;