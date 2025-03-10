import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';

/// Pressing Enter in a quote block will insert a newline (\n) within the quote,
/// while pressing Shift+Enter in a quote will insert a new paragraph next to the quote.
///
/// - support
///   - desktop
///   - mobile
///   - web
///
final CharacterShortcutEvent insertNewLineInQuoteBlock = CharacterShortcutEvent(
  key: 'insert a new line in quote block',
  character: '\n',
  handler: _insertNewLineHandler,
);

CharacterShortcutEventHandler _insertNewLineHandler = (editorState) async {
  final selection = editorState.selection?.normalized;
  if (selection == null) {
    return false;
  }

  final node = editorState.getNodeAtPath(selection.start.path);
  if (node == null || node.type != QuoteBlockKeys.type) {
    return false;
  }

  // delete the selection
  await editorState.deleteSelection(selection);

  if (HardwareKeyboard.instance.isShiftPressed) {
    await editorState.insertNewLine();
  } else if (node.children.isEmpty) {
    // insert a new paragraph within the callout block
    final path = node.path.child(0);
    final transaction = editorState.transaction;
    transaction.insertNode(
      path,
      paragraphNode(),
    );
    transaction.afterSelection = Selection.collapsed(
      Position(
        path: path,
      ),
    );
    await editorState.apply(transaction);
  }

  return true;
};
