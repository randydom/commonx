unit FileProxy;

{x$DEFINE BAD_PATTERN_CHECK}
{x$DEFINE PX_DEBUG}
{x$DEFINE DISABLE_WRITES}
{$DEFINE ATS}

interface
{$IFDEF MSWINDOWS}
{ NOTE!  THIS REQUIRES WINDOWS, it is a mistake to include this
  file in other platforms.
}

uses System.Sysutils, debug, numbers, systemx, windows;



function FileReadPx(ats: PAlignedTempSpace; Handle: THandle; var Buffer; Count: LongWord): Integer;inline;
function FileWritePx(ats: PAlignedTempSpace; Handle: THandle; const Buffer; Count: LongWord): Integer;inline;
function FileSeekPx(Handle: THandle; const Offset: Int64; Origin: Integer): Int64;inline;


{$IFDEF BAD_PATTERN_CHECK}
const
  BAD_PATTERN: array [0..9] of byte = ($0f, $00, $00, $00, $00, $00, $00, $00, $00, $18);
{$ENDIF}

{$ENDIF}
implementation

{$IFDEF MSWINDOWS}
function FileReadPx(ats: PAlignedTempSpace; Handle: THandle; var Buffer; Count: LongWord): Integer;inline;
begin
{$IFNDEF ATS}
  ats := nil;
{$ENDIF}
  if ats = nil then begin
    result := FileRead(Handle, buffer, count);
  {$IFDEF PX_DEBUG}
    Debug.Log('FileReadPx '+memorytohex(pbyte(@buffer), lesserof(count, 64)));
  {$ENDIF}
  end else begin
    result := FileRead(Handle, ats.aligned^, lesserof(count,262144));
    Movemem32(@buffer, ats.aligned, result);
  end;
end;

function FileWritePx(ats: PAlignedTempSpace; Handle: THandle; const Buffer; Count: LongWord): Integer;inline;
begin
{$IFNDEF ATS}
  ats := nil;
{$ENDIF}
  if ats = nil then begin
  {$IFDEF BAD_PATTERN_CHECK}
    AlertMemoryPattern(@BAD_PATTERN[0], sizeof(BAD_PATTERN), pbyte(@Buffer), count);
  {$ENDIF}
  {$IFDEF PX_DEBUG}
    Debug.Log('FileWritePx '+memorytohex(pbyte(@buffer), lesserof(count, 64)));
  {$ENDIF}
  {$IFDEF DISABLE_WRITES}
    Debug.Log('WRITES ARE DISABLED: '+memorytohex(pbyte(@buffer), lesserof(count, 64)));
    result := count;
  {$ELSE}
    result := FileWrite(Handle, buffer, count);
  {$ENDIF}
  end
  else begin
  {$IFDEF DISABLE_WRITES}
    Debug.Log('WRITES ARE DISABLED: '+memorytohex(pbyte(@buffer), lesserof(count, 64)));
    result := count;
  {$ELSE}
    Movemem32(ats.aligned,@buffer, lesserof(count,262144));
    result := fileWrite(Handle, ats.aligned^, count);
  {$ENDIF}
  end;

end;

function FileSeekPx(Handle: THandle; const Offset: Int64; Origin: Integer): Int64;inline;
begin
  {$IFDEF PX_DEBUG}
    Debug.Log('FileSeekPx 0x'+inttohex(offset, 16));
  {$ENDIF}
    result := FileSeek(Handle, offset, origin);
end;


{$ENDIF}
end.
