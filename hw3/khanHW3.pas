program khanHW3;

{ NAME: Camron Khan                                                            }
{ DATE: November 22, 2017                                                      }
{ COURSE: CSC 540 - Graduate Research                                          }
{ DESCRIPTION: This program simulates a 37-slot roulette table.  It requires   }
{     the number of requested spins and a target number to track.  Upon        }
{     completion the program generates data related to the doubles, triples,   }
{     and even/odd runs, and it outputs this aggregated data to the console    }
{     for the user.                                                            }
{ DATA: Below is sample data generated for HW3 (NOTE: All data is representing }
{     the number of spins, and the target number selected was 13).             }
{                                                                              }
{ --------------  ------------  -------------  -----------  --------  -------  }
{      NUM SPINS  AVG DBL FREQ  AVG TRPL FREQ  1ST TGT DBL  EVEN RUN  ODD RUN  }
{ --------------  ------------  -------------  -----------  --------  -------  }
{         10,000         33.92         907.80          611        13       12  }
{      1,000,000         35.76        1350.20         1674        19       16  }
{    100,000,000         35.98        1376.50         2192        25       29  }
{ 10,000,000,000         35.99        1369.11         1212        33       30  }

uses    sysutils;

const   wheelLength = 37;

var     i,
        currentSpin,
        resultN,
        resultNMinusOne,
        resultNMinusTwo,
        targetNum                   : integer;
        numSpins,
        totalDoubles,
        totalTriples,
        totalSpinsBetweenDoubles,
        totalSpinsBetweenTriples,
        numSpinsSinceLastDouble,
        numSpinsSinceLastTriple,
        numSpinsForTargetDouble,
        longestRunEvens,
        longestRunOdds,
        currentRunEvens,
        currentRunOdds              : qword;

procedure initializeVars();
  begin
    currentSpin := 0;
    resultN := -1;
    resultNMinusOne := -1;
    resultNMinusTwo := -1;
    targetNum := -1;
    totalDoubles := 0;
    totalTriples := 0;
    totalSpinsBetweenDoubles := 0;
    totalSpinsBetweenTriples := 0;
    numSpinsSinceLastDouble := 0;
    numSpinsSinceLastTriple := 0;
    numSpinsForTargetDouble := 0;
    longestRunEvens := 0;
    longestRunOdds := 0;
    currentRunEvens := 0;
    currentRunOdds := 0;
  end; {initializeVars}

procedure getUserInput();
  {get user's desired number of spins and target number}
  begin
    WriteLn('--------------------');
    WriteLn('WELCOME TO ROULETTE!');
    WriteLn('--------------------');
    repeat
      write('Enter the number of spins: ');
      readln(numSpins);
    until numSpins > 0;
    repeat
      write('Select a number between 0 and 36: ');
      readln(targetNum);
    until (targetNum >= 0) and (targetNum <= 36);
    WriteLn();
    WriteLn();
  end; {getUserInput}

procedure updateResults(val: integer);
  {keep track of the last 3 spins to track doubles and triples spun}
  begin
    resultNMinusTwo := resultNMinusOne;
    resultNMinusOne := resultN;
    resultN := val;
  end; {updateResults}

procedure evalTargetDoubles();
  {evaluate if a double of the target number has been spun}
  {tracks number of spins required to spin first double of target number}
  begin
    if ((resultN = targetNum) and (numSpinsForTargetDouble = 0)) then
      numSpinsForTargetDouble := currentSpin;
  end; {evalTargetDoubles}

procedure doublesSpun();
  {increment counters for number of doubles and number of spins between doubles}
  {reset counter tracking number of spins between doubles}
  begin
    evalTargetDoubles();
    totalDoubles += 1;
    totalSpinsBetweenDoubles += numSpinsSinceLastDouble;
    numSpinsSinceLastDouble := 0;
  end; {doublesSpun}

procedure doublesNotSpun();
  {increment counter for number of spins between doubles}
  begin
    numSpinsSinceLastDouble += 1;
  end; {doublesNotSpun}

procedure triplesSpun();
  {increment counters for number of triples and number of spins between triples}
  {reset counter tracking number of spins between triples}
  begin
    totalTriples += 1;
    totalSpinsBetweenTriples += numSpinsSinceLastTriple;
    numSpinsSinceLastTriple := 0;
  end; {triplesSpun}

procedure triplesNotSpun();
  {increment counter for number of spins between triples}
  begin
    numSpinsSinceLastTriple += 1;
  end; {triplesNotSpun}

procedure doEvenRun();
  {increment counter tracking evens run}
  begin
    currentRunEvens += 1;
  end; {doEvenRun}

procedure doOddRun();
  {increment counter tracking odds run}
  begin
    currentRunOdds += 1;
  end; {doOddRun}

procedure endEvenRun();
  {check if current even run is longer than longest previous even run}
  {if so, update}
  {reset even run counter}
  begin
    if (currentRunEvens > longestRunEvens) then
       longestRunEvens := currentRunEvens;
    currentRunEvens := 0;
  end; {endEvenRun}

procedure endOddRun();
  {check if current odd run is longer than longest previous odd run}
  {if so, update}
  {reset odd run counter}
  begin
    if (currentRunOdds > longestRunOdds) then
       longestRunOdds := currentRunOdds;
    currentRunOdds := 0;
  end; {endOddRun}

procedure updateCountMetrics();
  {monitor last three spins to determine doubles, triples, and even/odd runs}
  begin
    {check for double}
    if (resultN = resultNMinusOne) then
       doublesSpun()
    else
      doublesNotSpun();
    {check for triple}
    if ((resultN = resultNMinusOne) and (resultNMinusOne = resultNMinusTwo)) then
       triplesSpun()
    else
      triplesNotSpun();
    {check for even/odd runs}
    if (resultN = 0) then
      begin
        endEvenRun();
        endOddRun();
      end;
    if ((resultN mod 2) = 0) then
      begin
        doEvenRun();
        endOddRun();
      end
    else
      begin
        doOddRun();
        endEvenRun();
      end;
  end; {updateCountMetrics}

function calcAvg(total, n: integer): double;
  {calculates the average given a total and number of observations}
  {returns -1 if no observations}
  begin
    if (n > 0) then
       calcAvg := total / n
    else
      calcAvg := -1;
  end; {calcAvg}

procedure displayMetrics();
  {send data to console}
  var avgSpinsPerDoubles, avgSpinsPerTriples: double;
  begin
    {diplay general metrics}
    writeln('-------');
    writeln('GENERAL');
    writeln('-------');
    writeln('Total spins: ', currentSpin);
    WriteLn();
    WriteLn();

    {display doubles metrics}
    writeln('-------');
    writeln('DOUBLES');
    writeln('-------');
    writeln('Total doubles: ', totalDoubles);
    avgSpinsPerDoubles := calcAvg(totalSpinsBetweenDoubles, totalDoubles);
    if (avgSpinsPerDoubles > 0) then
      writeln('Average number of spins between doubles: ',
                        FormatFloat('0.00', avgSpinsPerDoubles));
    WriteLn();
    WriteLn();

    {display triples metrics}
    writeln('-------');
    writeln('TRIPLES');
    writeln('-------');
    writeln('Total triples: ', totalTriples);
    avgSpinsPerTriples := calcAvg(totalSpinsBetweenTriples, totalTriples);
    if (avgSpinsPerTriples > 0) then
      writeln('Average number of spins between triples: ',
                        FormatFloat('0.00', avgSpinsPerTriples));
    WriteLn();
    WriteLn();

    {display target metrics}
    writeln('------');
    writeln('TARGET');
    writeln('------');
    if (numSpinsForTargetDouble > 0) then
      writeln('Number of spins to hit doubles of number ', targetNum, ': ',
                                    numSpinsForTargetDouble)
    else
      writeln('No doubles were spun of number ', targetNum);
    WriteLn();
    WriteLn();

    {display even/odd metrics}
    writeln('--------');
    writeln('EVEN/ODD');
    writeln('--------');
    writeln('Longest evens run: ', longestRunEvens);
    writeln('Longest odds run: ', longestRunOdds);
    WriteLn();
    WriteLn();
  end; {displayMetrics}

procedure spinWheel();
  {engine to simulate spinning of the roulette wheel}
  {pseudorandomly generates a number between 0 and 36 inclusive}
  {increments current spin counter}
  var tempResult: integer;
  begin
      currentSpin += 1;
      tempResult := Random(wheelLength);
      updateResults(tempResult);
      updateCountMetrics();
  end; {spinWheel}

begin {main}
  randomize;
  initializeVars();
  getUserInput();
  for i := 1 to numSpins do
      spinWheel();
  displayMetrics();
  writeln('Press ENTER to exit');
  readln();
end. {main}

