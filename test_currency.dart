void main() {
  // Test the conversion rate
  double rwfToUsdRate = 1 / 1446.56;
  print('1 RWF = ${rwfToUsdRate.toStringAsFixed(8)} USD');

  // Test with sample prices
  double priceInRWF = 1446.56;
  double priceInUSD = priceInRWF * rwfToUsdRate;
  print(
    '${priceInRWF.toStringAsFixed(2)} RWF = \$${priceInUSD.toStringAsFixed(2)} USD',
  );

  // Test reverse - $1 USD should be 1446.56 RWF
  double testUSD = 1.0;
  double testRWF = testUSD * 1446.56;
  print('\$$testUSD USD = ${testRWF.toStringAsFixed(2)} RWF');

  // Test with typical product price
  double productPriceRWF = 15000; // 15,000 RWF
  double productPriceUSD = productPriceRWF * rwfToUsdRate;
  print(
    'Product: ${productPriceRWF.toStringAsFixed(0)} RWF = \$${productPriceUSD.toStringAsFixed(2)} USD',
  );
}
