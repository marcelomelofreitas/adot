unit CrossPlatform.Alg;

interface

uses
  System.SysUtils;

type
  TIteratorType = (itInput, itForward);

  TIterator<T> = record
  private
    type
      IInnerIterator = interface(IUnknown)
        function Iterator_Current: T;
        function Iterator_MoveNext: Boolean;
        function Iterator_EqualTo(const ADst: T): Boolean;
        function Iterator_Type: TIteratorType;
        function Iterator_EOF: Boolean;
        function Iterator_Copy: IInnerIterator;
      end;

    var
      FIterator: IInnerIterator;

    function GetCurrent: T;
    function GetIteratorType: TIteratorType;
    function GetEOF: Boolean;
  public
    class operator Equal(a, b: TIterator<T>): Boolean;
    class operator Equal(a: TIterator<T>; const b: T): Boolean;
    class operator Implicit(a: TIterator<T>): T;
    class operator Explicit(a: TIterator<T>): T;

    function MoveNext: Boolean;
    function Copy: TIterator<T>;

    property Current: T read GetCurrent;
    property IteratorType: TIteratorType read GetIteratorType;
    property EOF: Boolean read GetEOF;
  end;

  TUnaryPredicate<T> = reference to function(const AValue: T): Boolean;

  TAlg<T> = class
  public
    // Non-modifying sequence operations:
    class function all_of(AFirst, ALast: TIterator<T>; APred: TUnaryPredicate<T>): Boolean;
    class function any_of(AFirst, ALast: TIterator<T>; APred: TUnaryPredicate<T>): Boolean;
    class function none_of(AFirst, ALast: TIterator<T>; APred: TUnaryPredicate<T>): Boolean;
    class procedure for_each(AFirst, ALast: TIterator<T>; APred: TUnaryPredicate<T>);
    class function find(AFirst, ALast: TIterator<T>; const AValue: T): TIterator<T>;
  end;

implementation

{ TIterator<T> }

function TIterator<T>.GetCurrent: T;
begin
  result := FIterator.Iterator_Current;
end;

function TIterator<T>.GetEOF: Boolean;
begin
  result := FIterator.Iterator_EOF;
end;

function TIterator<T>.GetIteratorType: TIteratorType;
begin
  result := FIterator.Iterator_Type;
end;

function TIterator<T>.Copy: TIterator<T>;
begin
  result.FIterator := FIterator.Iterator_Copy;
end;

class operator TIterator<T>.Equal(a, b: TIterator<T>): Boolean;
begin
  if a.EOF then
    result := b.EOF
  else
    if b.EOF then
      result := False
    else
      result := a.FIterator.Iterator_EqualTo(b.FIterator.Iterator_Current);
end;

class operator TIterator<T>.Equal(a: TIterator<T>; const b: T): Boolean;
begin
  result := a.FIterator.Iterator_EqualTo(b);
end;

class operator TIterator<T>.Explicit(a: TIterator<T>): T;
begin
  result := a.FIterator.Iterator_Current;
end;

class operator TIterator<T>.Implicit(a: TIterator<T>): T;
begin
  result := a.FIterator.Iterator_Current;
end;

function TIterator<T>.MoveNext: Boolean;
begin
  result := FIterator.Iterator_MoveNext;
end;

{ TAlg<T><T> }

class function TAlg<T>.all_of(AFirst, ALast: TIterator<T>; APred: TUnaryPredicate<T>): Boolean;
begin
  if AFirst.EOF then
    result := ALast.EOF
  else
    if ALast.EOF then
      repeat
        if not APred(AFirst.Current) then
          Exit(False);
      until not AFirst.MoveNext
    else
      repeat
        if not APred(AFirst.Current) then
          Exit(False);
        if AFirst=ALast then
          Exit(True);
        if not AFirst.MoveNext then
          raise Exception.Create('Error');
      until False;
  result := True;
end;

class function TAlg<T>.any_of(AFirst, ALast: TIterator<T>; APred: TUnaryPredicate<T>): Boolean;
begin
  if AFirst.EOF then
    result := False
  else
    if ALast.EOF then
      repeat
        if APred(AFirst.Current) then
          Exit(True);
      until not AFirst.MoveNext
    else
      repeat
        if APred(AFirst.Current) then
          Exit(True);
        if AFirst=ALast then
          Exit(False);
        if not AFirst.MoveNext then
          raise Exception.Create('Error');
      until False;
  result := False;
end;

class function TAlg<T>.none_of(AFirst, ALast: TIterator<T>; APred: TUnaryPredicate<T>): Boolean;
begin
  if AFirst.EOF then
    result := True
  else
    if ALast.EOF then
    begin
      repeat
        if APred(AFirst.Current) then
          Exit(False);
      until not AFirst.MoveNext;
      result := True;
    end
    else
      repeat
        if APred(AFirst.Current) then
          Exit(False);
        if AFirst=ALast then
          Exit(True);
        if not AFirst.MoveNext then
          raise Exception.Create('Error');
      until False;
end;

class procedure TAlg<T>.for_each(AFirst, ALast: TIterator<T>; APred: TUnaryPredicate<T>);
begin
  if not AFirst.EOF then
    if ALast.EOF then
      repeat
        APred(AFirst.Current);
      until not AFirst.MoveNext
    else
      repeat
        APred(AFirst.Current);
        if AFirst=ALast then
          Exit;
        if not AFirst.MoveNext then
          raise Exception.Create('Error');
      until False;
end;

class function TAlg<T>.find(AFirst, ALast: TIterator<T>; const AValue: T): TIterator<T>;
begin
  if AFirst.EOF then
    result := ALast
  else
    if ALast.EOF then
    begin
      repeat
        if AFirst=AValue then
          Exit(AFirst);
      until not AFirst.MoveNext;
      result := ALast;
    end
    else
      repeat
        if AFirst=AValue then
          Exit(AFirst);
        if AFirst=ALast then
          Exit(ALast);
        if not AFirst.MoveNext then
          raise Exception.Create('Error');
      until False;
end;

end.
