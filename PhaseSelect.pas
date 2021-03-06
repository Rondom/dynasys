(* Dynasys, http://code.google.com/p/dynasys/
 * Copyright (C) 2009  Dynasys
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http:www.gnu.org/licenses/>.
 *)

unit PhaseSelect;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LCLProc, ColorBox, LMessages, StdCtrls, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, Buttons, ComCtrls,
    Liste,SimObjekt,  ErrorTxt;
const
  LB_ERR = -1;
type
  TPhasenAuswahl = class(TForm)
    ButtonPanel: TPanel;
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    HelpBtn: TBitBtn;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    GroupBox1: TGroupBox;
    SrcLabel: TLabel;
    DstLabel: TLabel;
    IncludeBtn: TSpeedButton;
    IncAllBtn: TSpeedButton;
    ExcludeBtn: TSpeedButton;
    ExAllBtn: TSpeedButton;
    SrcList: TListBox;
    DstList: TListBox;
    TabSheet2: TTabSheet;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ColorBox1: TColorBox;
    ColorBox2: TColorBox;
    ColorBox3: TColorBox;
    ColorBox4: TColorBox;
    TabSheet3: TTabSheet;
    GroupBox3: TGroupBox;
    RadioGroup1: TRadioGroup;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioGroup2: TRadioGroup;
    RadioButton4: TRadioButton;
    RadioButton3: TRadioButton;
    Label5: TLabel;
    Label6: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure IncludeBtnClick(Sender: TObject);
    procedure ExcludeBtnClick(Sender: TObject);
    procedure IncAllBtnClick(Sender: TObject);
    procedure ExAllBtnClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure MoveSelected(List: TCustomListBox; Items: TStrings; maxItems:integer);
    procedure SetItem(List: TListBox; Index: Integer);
    function GetFirstSelection(List: TCustomListBox): Integer;
    procedure SetButtons;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    SelCount:integer;
  public
    { Public declarations }
  end;

var
  PhasenAuswahl: TPhasenAuswahl;

implementation

{$R *.lfm}

procedure TPhasenAuswahl.FormCreate(Sender: TObject);
begin
  SelCount:=0;
end;

procedure TPhasenAuswahl.IncludeBtnClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := GetFirstSelection(SrcList);
  MoveSelected(SrcList, DstList.Items,2);
  Inc(SelCount);
  SetItem(SrcList, Index);
end;

procedure TPhasenAuswahl.ExcludeBtnClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := GetFirstSelection(DstList);
  MoveSelected(DstList, SrcList.Items,MaxInt);
  Dec(SelCount);
  SetItem(DstList, Index);
end;

procedure TPhasenAuswahl.IncAllBtnClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to SrcList.Items.Count - 1 do
    DstList.Items.AddObject(SrcList.Items[I],
      SrcList.Items.Objects[I]);
  SrcList.Items.Clear;
  SetItem(SrcList, 0);
end;

procedure TPhasenAuswahl.ExAllBtnClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to DstList.Items.Count - 1 do
    SrcList.Items.AddObject(DstList.Items[I], DstList.Items.Objects[I]);
  DstList.Items.Clear;
  SetItem(DstList, 0);
end;

procedure TPhasenAuswahl.FormPaint(Sender: TObject);
var i : integer;
begin
  SrcList.items.clear;
  SrcList.sorted:=false;
  DstList.items.clear;
  For i:=0 to ObjektListe.Count-1 do begin
    if ObjektListe.items[i].key=ZustandId then
         SrcList.items.add(ObjektListe.items[i].name)
  end;
  For i:=0 to ObjektListe.Count-1 do begin
    if (ObjektListe.items[i].key>0) and (ObjektListe.items[i].key<ZustandId)then
         SrcList.items.add(ObjektListe.items[i].name)
  end;
  if ObjektListe.Count>0 then SrcList.selected[0]:=true;
  SetButtons;
end;

procedure TPhasenAuswahl.MoveSelected(List: TCustomListBox; Items: TStrings; maxItems:integer);
var
  I: Integer;
begin
  for I := List.Items.Count - 1 downto 0 do
    if List.Selected[I] then begin
      if  (Items.count<maxItems) then
        begin
          Items.AddObject(List.Items[I], List.Items.Objects[I]);
          List.Items.Delete(I);
        end
      else
       MessageDlg(ErrorTxt30, mtInformation, [mbOk], 0);
    end;
end;

procedure TPhasenAuswahl.SetButtons;
var
  SrcEmpty, DstEmpty, DstFull: Boolean;
begin
  SrcEmpty := SrcList.Items.Count = 0;
  DstEmpty := DstList.Items.Count = 0;
  DstFull  := DstList.Items.Count >= 2;
  IncludeBtn.Enabled := not (SrcEmpty or DstFull);
  IncAllBtn.Enabled := SrcList.Items.Count+SrcList.Items.Count<=2;
                       //not (SrcEmpty or DstFull);
  ExcludeBtn.Enabled := not DstEmpty;
  ExAllBtn.Enabled := not DstEmpty;
end;

function TPhasenAuswahl.GetFirstSelection(List: TCustomListBox): Integer;
begin
  for Result := 0 to List.Items.Count - 1 do
    if List.Selected[Result] then Exit;
  Result := LB_ERR;
end;

procedure TPhasenAuswahl.SetItem(List: TListBox; Index: Integer);
var
  MaxIndex: Integer;
begin
  with List do
  begin
    SetFocus;
    MaxIndex := List.Items.Count - 1;
    if Index = LB_ERR then Index := 0
    else if Index > MaxIndex then Index := MaxIndex;
    Selected[Index] := True;
  end;
  SetButtons;
end;


procedure TPhasenAuswahl.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var msg:String;
begin
  if ModalResult=mrCancel then begin
  canclose:=true;
  Exit;
  end;
  if DstList.Items.Count<>2 then begin
    MessageDlg(ErrorTxt31,mtError,[mbok],0);
    CanClose:=False;  Exit;
  end;
end;

end.
