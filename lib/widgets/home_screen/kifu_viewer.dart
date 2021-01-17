import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Row(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.game.moves.length,
                itemBuilder: (_, index) => Container(
                  color: index == _currentIndex - 1 ? Theme.of(context).accentColor : Colors.transparent,
                  child: GestureDetector(
                    child: Text(widget.game.moves[index].asKif),
                    onTap: () => setState(() => _currentIndex = index + 1),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Column(
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
                      onPressed: _canSkipStart ? () => setState(() => _currentIndex = 0) : null,
                    ),
                    IconButton(
                      icon: Icon(Icons.fast_rewind),
                      onPressed: _canRewind ? () => setState(() => _currentIndex--) : null,
                    ),
                    IconButton(
                      icon: Icon(Icons.fast_forward),
                      onPressed: _canFastForward ? () => setState(() => _currentIndex++) : null,
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_next),
                      onPressed:
                          _canSkipEnd ? () => setState(() => _currentIndex = widget.game.gameBoards.length - 1) : null,
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
