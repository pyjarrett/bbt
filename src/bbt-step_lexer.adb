with BBT.IO;
with BBT.Settings;

with Ada.Characters.Latin_1;
with Ada.Containers.Indefinite_Vectors;
with Ada.Strings.Fixed;                 use Ada.Strings.Fixed;
with Ada.Strings.Maps.Constants;

package body BBT.Step_Lexer is

   -- --------------------------------------------------------------------------
   -- IO renamed with local Topic
   procedure Put_Line
     (Item  : String;
      File  : String  := "";
      Line  : Integer := 0;
      Level : BBT.Settings.Print_Out_Level := BBT.IO.Normal;
      Topic : Settings.Extended_Topics := Settings.Step_Lexer)
      renames IO.Put_Line;


   package Internal is

      -- --------------------------------------------------------------------------
      type Token_Type is (Keyword, Identifier, Code_Span, Empty);
      -- In Markdown, Code_Span denote a word or phrase enclosed in backticks (`).
      -- Refer to https://spec.commonmark.org/0.31.2/#code-spans
      -- for specification
      -- In BBT, backticks enclose the command to run, or a file name,
      -- or an expected output.

      procedure Initialize_Cursor;

      function Next_Token (Line     : access constant String;
                           Tok_Type : out Token_Type)
                           return String;

      function More_Token return Boolean;

      function Is_A_Keyword (S     : access constant String;
                             First : Positive;
                             Last  : Natural := 0
                            ) return Boolean;

   end Internal;

   package body Internal is

      Cursor         : Natural := 1;
      Line_Finished  : Boolean := False;
      Backtick       : constant Character := '`';

      The_Delimiters : constant Ada.Strings.Maps.Character_Set
        := Ada.Strings.Maps.To_Set (" " & Ada.Characters.Latin_1.HT);

      package String_Arrays is new Ada.Containers.Indefinite_Vectors (Positive,
                                                                      String);
      Keywords : constant String_Arrays.Vector :=
                   ["given",
                    "when",
                    "then",
                    "and",
                    "but",
                    "run",
                    "get",
                    "existing",
                    "no",
                    "error",
                    "file",
                    "contains",
                    "Successfully"
                   ];

      -- 0 means not found

      -- --------------------------------------------------------------------------
      procedure Initialize_Cursor is begin
         Cursor := 1;
         Line_Finished := False;
      end Initialize_Cursor;

      -- --------------------------------------------------------------------------
      function Next_Token (Line     : access constant String;
                           Tok_Type : out Token_Type)
                           return String is
         First : Positive;      -- Index of first character in token
         Last  : Natural := 0;  -- Index of last character in token

         -- Note that Cursor is >= Last
         -- Cursor is the point where next call to Next_Token will start,
         -- Last is the last character of the Token
         -- In the case of a code span, Last will designate a character before
         -- the closing backtick, and the cursor the character after.

         procedure Finish_Line is
         begin
            Line_Finished := True;
            Cursor := 1;
         end Finish_Line;

      begin
         Find_Token (Source => Line.all (Cursor .. Line'Last),
                     Set    => The_Delimiters,
                     Test   => Ada.Strings.Outside,
                     First  => First,
                     Last   => Last);
         Put_Line ("processing token = """ & Line.all (First .. Last) &
                     """ in " & Line.all,
                   Level => IO.Debug);
         Cursor := (Natural'Min (Line.all'Length, Last + 1));
         -- Jump to next char unless already on the last
         if Is_A_Keyword (Line, First, Last) then
            -- Keyword ---------------------------------------------------------
            Tok_Type := Keyword;
            Put_Line ("Found Keyword """ & Line.all (First .. Last) &
                        """ in " & Line.all,
                      Level => IO.Debug);

         elsif Line (First) = Backtick then
            if Line'Last > First and then Line (First + 1) /= Backtick then
               -- Code span start
               -- Note that we test also First + 1 because
               -- "``" is not a code span start, backtick should not be
               -- followed by another
               Last := Index (Line.all,
                              [Backtick],
                              From => First + 1);
               if Last = 0 then
                  IO.Put_Error ("Missing closing backtick in """ &
                                  Line.all (Cursor .. Line'Last));
                  Finish_Line;
               else
                  -- Code span -------------------------------------------------
                  Cursor := Last + 1; -- the cursor goes over the final backtick
                  First := @ + 1; -- remove first backtick
                  Last  := @ - 1; -- remove final backtick

                  Put_Line ("Found code span = """ & Line.all (First .. Last) &
                              """ in " & Line.all,
                            Level => IO.Debug);
                  Tok_Type := Code_Span;
               end if;

            else
               -- Jump over "``"
               Tok_Type := Empty;
               Cursor := First + 2;

            end if;

         else
            -- Identifier ------------------------------------------------------
            Tok_Type := Identifier;

         end if;

         if Cursor >= Line.all'Last then
            -- It's the end of line
            -- -> next line.
            Finish_Line;
            -- Put_Line ("EOL");
         end if;

         if Last = 0 then
            -- nothing found
            Finish_Line;
            Tok_Type := Empty;

            return ""; ---------------------------------------------------------

         else
            return (Line.all (First .. Last)); ---------------------------------

         end if;

      end Next_Token;

      -- -----------------------------------------------------------------------
      function More_Token return Boolean is
      begin
         return not Line_Finished;
      end More_Token;

      -- --------------------------------------------------------------------------
      function Is_A_Keyword (S      : access constant String;
                             First  : Positive;
                             Last   : Natural := 0)
                             return Boolean is
      begin
         return Keywords.Contains
           (Translate (Source  => S.all (First .. Last),
                       Mapping => Ada.Strings.Maps.Constants.Lower_Case_Map));
      end Is_A_Keyword;

   end Internal;

   use Internal;

   -- --------------------------------------------------------------------------
   function Parse (Line : Unbounded_String) return Step_Details is
      First_Token     : Boolean                  := True;
      The_Kind        : Step_Kind                := Unknown;
      Cat             : Extended_Step_Categories := Unknown;
      Cmd             : Unbounded_String;
      Expected_Output : Unbounded_String;
      Get_Form        : Boolean := False;
      -- Line format :
      -- Run_Cmd              : when I run `cmd`
      -- No_Error_Return_Code : then I get no error
      -- Std_Output           : and  I get error `msg`
      Previous_Token  : Unbounded_String;


   begin
      Initialize_Cursor;

      Put_Line ("Parsing """ & To_String (Line) & """", Level => IO.Debug);
      Line_Processing : while More_Token loop
         declare
            TT   : Token_Type;
            Tmp  : aliased constant String := To_String (Line);
            Tok  : constant String := Next_Token (Tmp'Access, TT);

         begin
            case TT is
               when Keyword =>
                  -- Put_Line ("   Keyword    : """ & Tok & """");
                  -- Put_Line ("   Previous   : """ & To_String (Previous_Token) & """");
                  declare
                     Lower_Keyword : constant String := Translate
                       (Source  => Tok,
                        Mapping => Ada.Strings.Maps.Constants.Lower_Case_Map);
                  begin
                     if First_Token then
                        if    Lower_Keyword = "given" then
                           Cat := Given_Step;
                        elsif Lower_Keyword = "when" then
                           Cat := When_Step;
                        elsif Lower_Keyword = "then" then
                           Cat := Then_Step;
                        else
                           null;
                           IO.Put_Warning ("   Keyword : " & Tok & " ignored");
                        end if;
                     else
                        null;
                        -- given/when/then may appear later on the line, but
                        -- then are not considered as keywords.
                     end if;

                     if Lower_Keyword = "run" then
                        The_Kind := Run_Cmd;

                     elsif Lower_Keyword = "get" then
                        Get_Form := True;

                     elsif Lower_Keyword = "error" then
                        -- Put_Line ("   error");
                        if Previous_Token = "no" then
                           -- Put_Line (" ========= NO  error", Level => IO.Quiet);
                           The_Kind := No_Error_Return_Code;
                        else
                           -- Put_Line (" ========= error : ", Level => IO.Quiet);
                           The_Kind := Error_Return_Code;
                        end if;
                     end if;

                     Previous_Token := To_Unbounded_String (Lower_Keyword);

                  end;

               when Identifier =>
                  -- Put_Line ("   Identifier : " & Tok);
                  null;

               when Code_Span =>
                  -- Put_Line (" ====== Code span ====== : " & Tok);
                  if The_Kind = Run_Cmd then
                     Cmd := To_Unbounded_String (Tok);
                     -- IO.Put_Error (" ========= Run_Cmd : " & Tok);

                  elsif Get_Form then
                     -- Get keywords + code span means that the code span
                     -- is the message expected
                     The_Kind := Std_Output;
                     Expected_Output := Cmd;
                     -- this a single line text
                     -- IO.Put_Line (" ========= Std_Output : " & Tok);

                  else
                     IO.Put_Warning ("Code span ignored in """ & Tok & """");

                  end if;

               when Empty =>
                  -- Put_Line ("   Empty line");
                  null;

            end case;

         end;
         First_Token := False;

      end loop Line_Processing;

      case The_Kind is
         when Run_Cmd =>
            return Step_Details'(Kind => Run_Cmd,
                                 Text => Line,
                                 Cat  => Cat,
                                 Cmd  => Cmd);
         when Error_Return_Code =>
            return Step_Details'(Kind      => Error_Return_Code,
                                 Text      => Line,
                                 Cat       => Cat);
         when No_Error_Return_Code =>
            return Step_Details'(Kind      => No_Error_Return_Code,
                                 Text      => Line,
                                 Cat       => Cat);
         when Std_Output =>
            return Step_Details'(Kind             => Std_Output,
                                 Text             => Line,
                                 Cat              => Cat,
                                 Expected_Output  => Expected_Output);
         when Unknown =>
            return Step_Details'(Kind             => Unknown,
                                 Text             => Line,
                                 Cat              => Cat);
      end case;

   end Parse;


end BBT.Step_Lexer;
