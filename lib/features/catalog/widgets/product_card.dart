import 'package:flutter/material.dart';

import '../../../data/models/producto.dart';
import '../../../data/models/productor.dart';
import '../../../utils/formatters.dart';
import '../../../utils/image_resolver.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.producto,
    this.productor,
    this.onAdd,
    this.onTap,
    this.showAddButton = true,
  });

  final Producto producto;
  final ProductorModel? productor;
  final VoidCallback? onAdd;
  final VoidCallback? onTap;
  final bool showAddButton;

  List<String> _resolveImages() {
    return producto.imagenes
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .map(resolveImageUrl)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedImages = _resolveImages();
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (resolvedImages.isNotEmpty)
              _ProductImageCarousel(imageUrls: resolvedImages)
            else
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.grey.shade200,
                  child: const Center(child: Icon(Icons.image_not_supported)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          producto.nombre,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        formatMoney(producto.precioActual),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.green.shade700),
                      ),
                    ],
                  ),
                  if (producto.tienePrecioMayorista &&
                      producto.precioMayorista != null &&
                      producto.cantidadMinimaMayorista != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Mayorista: ${formatMoney(producto.precioMayorista!)} '
                      'desde ${producto.cantidadMinimaMayorista} u.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.green.shade800),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    producto.descripcion,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: [
                      Chip(
                        label: Text('${producto.stock.toStringAsFixed(0)} en stock'),
                      ),
                      Chip(label: Text(producto.unidadMedida)),
                      if (productor != null)
                        Chip(label: Text('Productor: ${productor!.nombreUsuario}')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: showAddButton
                        ? FilledButton.icon(
                            onPressed: onAdd,
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Agregar'),
                          )
                        : onTap != null
                            ? OutlinedButton.icon(
                                onPressed: onTap,
                                icon: const Icon(Icons.storefront),
                                label: const Text('Ver productor'),
                              )
                            : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImageCarousel extends StatefulWidget {
  const _ProductImageCarousel({required this.imageUrls});

  final List<String> imageUrls;

  @override
  State<_ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<_ProductImageCarousel> {
  late final PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final imageUrl = widget.imageUrls[index];
              return Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
              );
            },
          ),
        ),
        if (widget.imageUrls.length > 1)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.imageUrls.length, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: isActive ? 18 : 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withOpacity(0.9)
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
