import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_shogi_board/flutter_shogi_board.dart';
import 'package:shogi/shogi.dart';

class KifuViewer extends StatefulWidget {
  KifuViewer({
    Key key,
    @required this.game,
  }) : super(key: key);

  final Game game;

  @override
  _KifuViewerState createState() => _KifuViewerState();
}

class _KifuViewerState extends State<KifuViewer> {
  int _currentIndex = 0;

  GameBoard get gameBoard => widget.game.gameBoards[_currentIndex];
  bool get _canSkipStart => _currentIndex != 0;
  bool get _canRewind => _currentIndex > 0;
  bool get _canFastForward => _currentIndex < widget.game.gameBoards.length - 1;
  bool get _canSkipEnd => _currentIndex != widget.game.gameBoards.length - 1;

  @override
  void didUpdateWidget(covariant KifuViewer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.game != widget.game) {
      _currentIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      shortcuts: {
        if (_canSkipStart) LogicalKeySet(LogicalKeyboardKey.arrowUp): const _NavigateIntent.start(),
        if (_canRewind) LogicalKeySet(LogicalKeyboardKey.arrowLeft): const _NavigateIntent.previous(),
        if (_canFastForward) LogicalKeySet(LogicalKeyboardKey.arrowRight): const _NavigateIntent.next(),
        if (_canSkipEnd) LogicalKeySet(LogicalKeyboardKey.arrowDown): const _NavigateIntent.end(),
      },
      actions: {
        _NavigateIntent: CallbackAction<_NavigateIntent>(
          onInvoke: (intent) => _navigate(intent.navigateType),
        ),
      },
      autofocus: true,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              width: 120,
              child: ListView.builder(
                itemCount: widget.game.moves.length,
                itemBuilder: (_, index) {
                  final isSelected = index == _currentIndex - 1;
                  return Container(
                    color: isSelected ? Theme.of(context).accentColor : Colors.transparent,
                    child: GestureDetector(
                      child: Text(
                        widget.game.moves[index].asKif,
                        style: Theme.of(context).textTheme.bodyText2.apply(
                              color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyText2.color,
                            ),
                      ),
                      onTap: () => setState(() => _currentIndex = index + 1),
                    ),
                  );
                },
              ),
            ),
            VerticalDivider(),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: ShogiBoard(
                      gameBoard: gameBoard,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.skip_previous),
                        onPressed: _canSkipStart ? () => _navigate(_NavigateType.start) : null,
                      ),
                      IconButton(
                        icon: Icon(Icons.fast_rewind),
                        onPressed: _canRewind ? () => _navigate(_NavigateType.previous) : null,
                      ),
                      IconButton(
                        icon: Icon(Icons.fast_forward),
                        onPressed: _canFastForward ? () => _navigate(_NavigateType.next) : null,
                      ),
                      IconButton(
                        icon: Icon(Icons.skip_next),
                        onPressed: _canSkipEnd ? () => _navigate(_NavigateType.end) : null,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(_NavigateType navigateType) {
    switch (navigateType) {
      case _NavigateType.start:
        if (_canSkipStart) {
          setState(() => _currentIndex = 0);
        }
        break;
      case _NavigateType.previous:
        if (_canRewind) {
          setState(() => _currentIndex--);
        }
        break;
      case _NavigateType.next:
        if (_canFastForward) {
          setState(() => _currentIndex++);
        }
        break;
      case _NavigateType.end:
        if (_canSkipEnd) {
          setState(() => _currentIndex = widget.game.gameBoards.length - 1);
        }
        break;
    }
  }
}

enum _NavigateType {
  start,
  previous,
  next,
  end,
}

class _NavigateIntent extends Intent {
  const _NavigateIntent.start() : navigateType = _NavigateType.start;
  const _NavigateIntent.previous() : navigateType = _NavigateType.previous;
  const _NavigateIntent.next() : navigateType = _NavigateType.next;
  const _NavigateIntent.end() : navigateType = _NavigateType.end;

  final _NavigateType navigateType;
}
