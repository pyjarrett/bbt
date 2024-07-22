-- -----------------------------------------------------------------------------
-- bbt, the black box tester (https://github.com/LionelDraghi/bbt)
-- Author : Lionel Draghi
-- SPDX-License-Identifier: APSL-2.0
-- SPDX-FileCopyrightText: 2024, Lionel Draghi
-- -----------------------------------------------------------------------------

with Ada.Directories;

package body BBT.Settings is

   -- --------------------------------------------------------------------------
   -- Most of the variable here are "write once, read more".
   -- To avoid the cost of Unbounded strings manipulation,
   -- they are implemented as access to String
   -- Runfl_Name      : access String := null;
   -- Cmd_Line        : Unbounded_String := Null_Unbounded_String;
   WD : constant access String :=
          new String'(Ada.Directories.Current_Directory);
   Outfile_Name, Exec_Dir_Name : access String := null;

   -- --------------------------------------------------------------------------
   --  function Is_File_In (File, Dir : String) return Boolean is
   --     Compared_Length : constant Natural := (if Dir (Dir'Last) = '*'
   --                                            then Dir'Length - 1
   --                                            else Dir'Length);
   --     -- return True if File is in Dir, supposing that both are full name.
   --     -- e.g. (Dir => /usr/*, File => /usr/lib/locale) return True
   --     -- e.g. (Dir => /usr/*, File => locale)          return False
   --  begin
   --     return (File'Length >= Compared_Length and then
   --             File (File'First .. File'First - 1 + Compared_Length)
   --             = Dir (Dir'First .. Dir'First  - 1 + Compared_Length));
   --  end Is_File_In;

   -- --------------------------------------------------------------------------
   function Initial_Directory return String is (WD.all);

   -- --------------------------------------------------------------------------
   procedure Set_Exec_Dir (Dir_Name : String) is
   begin
      Exec_Dir_Name := new String'(Dir_Name);
   end Set_Exec_Dir;

   function Exec_Dir return String is
     (if Exec_Dir_Name = null then Ada.Directories.Current_Directory
      else Exec_Dir_Name.all);

   -- --------------------------------------------------------------------------
   function Output_File_Dir return String is (Exec_Dir);

   -- --------------------------------------------------------------------------
   procedure Set_Result_File (File_Name : String) is
   begin
      Outfile_Name := new String'(File_Name);
   end Set_Result_File;

   function Result_File_Name return String  is
     (if Outfile_Name = null then ""
      else Outfile_Name.all);

   function Result_Dir return String is
     (if Outfile_Name = null then Ada.Directories.Current_Directory
      else Ada.Directories.Containing_Directory (Outfile_Name.all));

end BBT.Settings;
