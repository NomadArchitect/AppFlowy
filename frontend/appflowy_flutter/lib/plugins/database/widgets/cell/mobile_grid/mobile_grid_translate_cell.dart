import 'package:appflowy/plugins/database/application/cell/bloc/translate_cell_bloc.dart';
import 'package:appflowy/plugins/database/grid/presentation/layout/sizes.dart';
import 'package:appflowy/plugins/database/widgets/cell/desktop_grid/desktop_grid_translate_cell.dart';
import 'package:appflowy/plugins/database/widgets/cell/editable_cell_skeleton/translate.dart';
import 'package:appflowy/plugins/database/widgets/row/cells/cell_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

class MobileGridTranslateCellSkin extends IEditableTranslateCellSkin {
  @override
  Widget build(
    BuildContext context,
    CellContainerNotifier cellContainerNotifier,
    ValueNotifier<bool> compactModeNotifier,
    TranslateCellBloc bloc,
    FocusNode focusNode,
    TextEditingController textEditingController,
  ) {
    return ChangeNotifierProvider(
      create: (_) => TranslateMouseNotifier(),
      builder: (context, child) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          opaque: false,
          onEnter: (p) =>
              Provider.of<TranslateMouseNotifier>(context, listen: false)
                  .onEnter = true,
          onExit: (p) =>
              Provider.of<TranslateMouseNotifier>(context, listen: false)
                  .onEnter = false,
          child: Stack(
            children: [
              TextField(
                controller: textEditingController,
                readOnly: true,
                focusNode: focusNode,
                onEditingComplete: () => focusNode.unfocus(),
                onSubmitted: (_) => focusNode.unfocus(),
                style: Theme.of(context).textTheme.bodyMedium,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  contentPadding: GridSize.cellContentInsets,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  isDense: true,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: GridSize.cellVPadding,
                ),
                child: Consumer<TranslateMouseNotifier>(
                  builder: (
                    BuildContext context,
                    TranslateMouseNotifier notifier,
                    Widget? child,
                  ) {
                    if (notifier.onEnter) {
                      return TranslateCellAccessory(
                        viewId: bloc.cellController.viewId,
                        fieldId: bloc.cellController.fieldId,
                        rowId: bloc.cellController.rowId,
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ).positioned(right: 0, bottom: 0),
            ],
          ),
        );
      },
    );
  }
}
