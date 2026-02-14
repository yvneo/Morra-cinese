module manche(
  input [1:0] PRIMO, 
  input [1:0] SECONDO,
  input INIZIA,
  input clk, // Clock
  output reg [1:0] MANCHE,
  output reg [1:0] PARTITA
);

  // reset = 00
  // set-up = 01
  // game  = 10

  // Stato
  reg [1:0] statoAttuale = 2'b00;
  reg [1:0] statoProssimo = 2'b00;

  // Registri
  reg [4:0] regTurni;
  reg [2:0] regMossaPrecedente;
  reg [1:0] regPrimi4Turni;
  reg [3:0] regPunti;

  // output datapath to FSM
  reg fine = 1'b0;

  // output FSM to datapath
  reg setup = 1'b0;

  // reg solo per datapath
  reg mossaNonValida = 1'b0;
  reg mossaNonConsentita = 1'b0;
  reg ripetereIlTurno = 1'b0;

  // Cambio degli stato con il cambio di clock
  always @(posedge clk) begin
    statoAttuale <= statoProssimo;
  end

  // FSM
  always @(*) begin
    case (statoAttuale)
      2'b00: // Stato: reset
        if (INIZIA) begin 
          statoProssimo = 2'b01;
          setup = 1'b1;
        end else begin 
          statoProssimo = 2'b00;
          setup = 1'b1; // no play time
        end
      2'b01: // Stato: set-up
        if (INIZIA) begin
          statoProssimo = 2'b01;
          setup = 1'b1;
        end else begin
          statoProssimo = 2'b10;
          setup = 1'b0;
        end
      2'b10: // Stato: game
        if (INIZIA) begin
          statoProssimo = 2'b01;
          setup = 1'b1;
        end else begin
          if (fine) begin
            statoProssimo = 2'b00;
            setup = 1'b1; // no play time
          end else begin
            statoProssimo = 2'b10;
            setup = 1'b0;
          end
        end
      default: statoProssimo = 2'b00;
    endcase
  end

  // Datapath
  always @(posedge clk) begin
    if (setup) begin
      $display("Reset regs.");
      // Resetto tutti i registri con (stato: set-up)
      regTurni = {PRIMO, SECONDO} + 5'b00100;
      regMossaPrecedente = 3'b000;
      regPunti = 4'b0000;
      regPrimi4Turni = 2'b00;

      // Setto output Datapath
      fine = 1'b0;
      PARTITA = 2'b00;
      MANCHE = 2'b00; // dev
    end else begin

      // Controllo se la mossa non valida (mossa == 0)
      if (PRIMO == 2'b00 || SECONDO == 2'b00) begin
        mossaNonValida = 1'b1;
      end else begin
        mossaNonValida = 1'b0;
      end

      if (regMossaPrecedente[2] == 0) begin
        // Controlliamo giocatore PRIMO
        if (regMossaPrecedente[1:0] == PRIMO) mossaNonConsentita <= 1'b1;
        else mossaNonConsentita = 1'b0;
      end else begin
        // Controlliamo giocatore SECONDO
        if (regMossaPrecedente[1:0] == SECONDO) mossaNonConsentita <= 1'b1;
        else mossaNonConsentita = 1'b0;
      end

      if (mossaNonValida == 1'b1 || mossaNonConsentita == 1'b1) begin
        $display("Un giocatore ha giocato una mossa non valida");
        ripetereIlTurno = 1'b1;
      end else begin
        ripetereIlTurno = 1'b0;
      end

      // Turno valido
      if (ripetereIlTurno == 1'b0) begin

        // Diminuisco il numero dei turni
        regTurni = regTurni - 1;

        // Verifico se è un pareggio
        if (PRIMO == SECONDO) begin
          MANCHE = 2'b11; // Pareggio
          $display("Sono in pareggio");
        end else begin
          case ({PRIMO, SECONDO})
            4'b0111, 4'b1001, 4'b1110:
              MANCHE = 2'b01; // Vincita PRIMO
            default:
              MANCHE = 2'b10; // Vincita SECONDO
          endcase  
        end

        // Gestisco i punti e ultima mossa
        case (MANCHE)
          2'b10: begin
            regPunti = regPunti - 1;
            regMossaPrecedente = {1'b1, SECONDO};
          end
          2'b01: begin
            regPunti = regPunti + 1;
            regMossaPrecedente = {1'b0, PRIMO};
          end
          default: begin
            regPunti = regPunti;
            regMossaPrecedente = 3'b000;
          end
        endcase

        // Verifico che ha almeno fatto 4 turni
        if (regPrimi4Turni == 2'b11) begin
          // Verifico se qualcuno ha un vantaggio di due punti
          if (regPunti[2:0] >= 2 && regPunti[3] == 0) begin
            // Vince il giocatore PRIMO
            PARTITA = 2'b01;
            fine = 1'b1;
          end else if (regPunti[2:0] <= 6 && regPunti[3] == 1) begin
            // Vince il giocatore SECONDO
            PARTITA = 2'b10;
            fine <= 1'b1;
          end else if (regTurni == 5'b00000) begin
            // Nessuno ha vinto la partita, verifico se i turni sono finiti
            if (regPunti == 4'b0001) begin
              // Vince il giocatore PRIMO
              PARTITA = 2'b01;
            end else if (regPunti == 4'b1111) begin
              // Vince il giocatore SECONDO
              PARTITA = 2'b10;
            end else begin
              // Partita finita in pareggio
              PARTITA = 2'b11;
            end
            fine = 1'b1;
          end else begin
            // Partita non finita
            PARTITA = 2'b00;
            fine = 1'b0;
          end
        end else begin
          PARTITA = 2'b00;
          // Aumento il turno di uno
          regPrimi4Turni = regPrimi4Turni + 1;
        end

      end else begin
        MANCHE = 2'b00; // Manche non valida
        PARTITA = 2'b00; // Partita non finita
      end
    end
    $display("Turni: %d, Punti: %b, Stato: %b, setup: %b, fine: %b", regTurni, regPunti, statoAttuale, setup, fine);
  end
endmodule