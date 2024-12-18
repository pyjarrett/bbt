-- -----------------------------------------------------------------------------
-- bbt, the black box tester (https://github.com/LionelDraghi/bbt)
-- Author : Lionel Draghi
-- SPDX-License-Identifier: APSL-2.0
-- SPDX-FileCopyrightText: 2024, Lionel Draghi
-- -----------------------------------------------------------------------------

with Ada.Directories;
with Ada.Text_IO; use Ada.Text_IO;

separate (BBT.Main)

procedure Create_Template is
   Template  : File_Type;
   File_Name : String renames Settings.Template_Name;

begin
   if Ada.Directories.Exists (File_Name) then
      IO.Put_Error ("File " & File_Name & " already exists", IO.No_Location);

   else
      Create (Template, Name => Settings.Template_Name);
      Set_Output (Template);

      Put_Line ("## Feature : Command line");
      New_Line;
      Put_Line ("Your comments here : it's just normal markdown text.");
      New_Line;
      Put_Line ("### Scenario : version message");
      Put_Line ("  - Given the `config.ini` file");
      Put_Line ("  ```");
      Put_Line ("  verbose=false");
      Put_Line ("  ```");
      Put_Line ("  - When I run `sut --version`");
      Put_Line ("  - Then I get no error");
      Put_Line ("  - And I get `sut v0.1.0`");
      Put_Line ("  (or ""- And Output is `sut v0.1.0`""");
      New_Line;
      Put_Line ("  Both above form test that the output is exactly `sut v0.1.0`");
      Put_Line ("  If what you want is just test that the output contains that string, then use:");
      Put_Line ("  - Then output contains `sut v0.1.0`");
      Put_Line ("  If what you want is just test that the output contains more lines, then use:");
      Put_Line ("  - Then output contains `expected.txt`");
      New_Line;
      Put_Line ("Preconditions common to several scenarios may be put in a Background section, before scenarios :");
      Put_Line ("### Background:");
      Put_Line ("  - Given there is no `input.txt` file");
      Put_Line ("  - Given there is a `tmp` dir");
      New_Line;
      Put_Line ("More extensive explanations : https://github.com/LionelDraghi/bbt/tree/main");
      New_Line;
      Put_Line ("File generated with BBT " & Settings.BBT_Version);

      Close (Template);
      Set_Output (Standard_Output);

      Put_Line ("Template file " & File_Name & " created.");

   end if;

end Create_Template;
