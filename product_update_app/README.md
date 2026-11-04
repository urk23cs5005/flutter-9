# Update Product Details using Google Firestore - Ex. 9

Flutter app that searches a product by name in the pre-filled Firestore collection `products`
(`where('name', isEqualTo: name).limit(1).get()`), fills New Quantity / New Price with the current
values, and on UPDATE writes them back with `doc(id).update({...})`, re-reads the document and
shows the updated details. The app never creates or deletes products.

## 1. Create the Flutter project files

```bash
cd product_update_app
flutter create .        # generates android/ etc. (keeps lib/ and pubspec.yaml)
flutter pub get
```

## 2. Connect your Firebase project

This lab uses **FlutterFire** (`firebase_options.dart`) instead of `google-services.json`.

1. Firebase Console -> create a project, **Firestore Database -> Create database (test mode)**.
2. Add the documents to collection `products` by hand: fields `name` (string), `quantity` (number), `price` (number).
   Sample: Pen 100 / 10, Notebook 50 / 45, Pencil 200 / 5. Search is case-sensitive.
3. Install the tools and link the app (this **overwrites** the placeholder `lib/firebase_options.dart`):

```bash
dart pub global activate flutterfire_cli     # needs the Firebase CLI: npm i -g firebase-tools, firebase login
flutterfire configure
```

4. Run on an Android emulator or phone: `flutter run`

(If `flutterfire configure` raises the Android minSdk requirement, set `minSdk = 23`
in `android/app/build.gradle(.kts)`.)

## Test cases from the lab record (sample data above)

| No. | Action | Result |
|-----|--------|--------|
| 1 | Search "Notebook" | Name Notebook, Quantity 50, Price Rs. 45.0; fields prefilled 50 / 45.0 |
| 2 | Set quantity 75, price 50, UPDATE | "Product updated successfully"; shows 75 / Rs. 50.0; document updated |
| 3 | Search "Marker" | "Product not found"; no details |
| 4 | UPDATE without searching | "Search for a product first" |
| 5 | Empty name, SEARCH | "Enter a product name" |
| 6 | Quantity "abc", UPDATE | "Enter a valid quantity and price" |

## Structure

```
lib/main.dart              ProductService (find / get / update) + ProductApp UI
lib/firebase_options.dart  PLACEHOLDER - regenerate with `flutterfire configure`
test/widget_test.dart      Tests for the UPDATE input rules
screenshots/               Images from the lab record
```
