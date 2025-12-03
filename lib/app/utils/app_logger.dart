import 'package:logger/logger.dart';

final logger = (Type type) => Logger(
  printer: AppLogger(type.toString()),
);

final detailLogger = (Type type) => Logger(
  printer: DetailLogger(type.toString()),
  //filter: DevelopmentFilter() // opcional(Define o filtro de nivel do log)
);

class AppLogger extends LogPrinter {
  final String className;
  AppLogger(this.className);
  
  @override
  List<String> log(LogEvent event) {
    final color = PrettyPrinter.defaultLevelColors[event.level];
    final emoji = PrettyPrinter.defaultLevelEmojis[event.level];
    final message = event.message;

    return [color!('$emoji: $className: $message')];
  }
  
}

// o PrettyPrinter é uma extensão do LogPrinter
class DetailLogger extends PrettyPrinter {
  final String className;
  DetailLogger(
    this.className, {
      super.methodCount = 2, // qtd de metodos no stack tracer
      super.errorMethodCount = 8, // stack tracer maior para error
      super.lineLength = 120, // largura da linha
      super.colors = true,
      super.printEmojis = true,
      super.printTime = true,
    }
  );
  
  @override
  List<String> log(LogEvent event) {
    var modifiedEvent = LogEvent(
      event.level, '$className: ${event.message}',
      error: event.error,
      stackTrace: event.stackTrace,
      time: event.time,
    );

    return super.log(modifiedEvent);
  }
  
}