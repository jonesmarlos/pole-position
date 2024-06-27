unit Packets;

interface

const
  PACKET_MOTION_ID: UInt8 = 0;
  PACKET_SESSION_ID = 1;
  PACKET_LAP_ID = 2;
  PACKET_EVENT_ID = 3;
  PACKET_PARTICIPANTS_ID = 4;
  PACKET_CARSETUP_ID = 5;
  PACKET_CARTELEMETRY_ID = 6;
  PACKET_CARSTATUS_ID = 7;
  PACKET_FINALCLASSIFICATION_ID = 8;
  PACKET_LOBBYINFO_ID = 9;
  PACKET_CARDAMAGE_ID = 10;
  PACKET_SESSIONHISTORY_ID = 11;
  PACKET_TYRESETS_ID = 12;
  PACKET_MOTIONEX_ID = 13;

type
  TPacketHeader = packed record
    m_packetFormat: UInt16;             // 2023
    m_gameYear: UInt8;                  // Game year - last two digits e.g. 23
    m_gameMajorVersion: UInt8;          // Game major version - "X.00"
    m_gameMinorVersion: UInt8;          // Game minor version - "1.XX"
    m_packetVersion: UInt8;             // Version of this packet type, all start from 1
    m_packetId: UInt8;                  // Identifier for the packet type, see below
    m_sessionUID: UInt64;               // Unique identifier for the session
    m_sessionTime: Single;              // Session timestamp
    m_frameIdentifier: UInt32;          // Identifier for the frame the data was retrieved on
    m_overallFrameIdentifier: UInt32;   // Overall identifier for the frame the data was retrieved
                                        // on, doesn't go back after flashbacks
    m_playerCarIndex: UInt8;            // Index of player's car in the array
    m_secondaryPlayerCarIndex: UInt8;   // Index of secondary player's car in the array (splitscreen)
                                        // 255 if no second player
  end;

type
  TCarMotionData = packed record
    m_worldPositionX: Single;           // World space X position - metres
    m_worldPositionY: Single;           // World space Y position
    m_worldPositionZ: Single;           // World space Z position
    m_worldVelocityX: Single;           // Velocity in world space X – metres/s
    m_worldVelocityY: Single;           // Velocity in world space Y
    m_worldVelocityZ: Single;           // Velocity in world space Z
    m_worldForwardDirX: Int16;          // World space forward X direction (normalised)
    m_worldForwardDirY: Int16;          // World space forward Y direction (normalised)
    m_worldForwardDirZ: Int16;          // World space forward Z direction (normalised)
    m_worldRightDirX: Int16;            // World space right X direction (normalised)
    m_worldRightDirY: Int16;            // World space right Y direction (normalised)
    m_worldRightDirZ: Int16;            // World space right Z direction (normalised)
    m_gForceLateral: Single;            // Lateral G-Force component
    m_gForceLongitudinal: Single;       // Longitudinal G-Force component
    m_gForceVertical: Single;           // Vertical G-Force component
    m_yaw: Single;                      // Yaw angle in radians
    m_pitch: Single;                    // Pitch angle in radians
    m_roll: Single;                     // Roll angle in radians
  end;

  TPacketMotionData = packed record
    m_header: TPacketHeader;                          // Header
    m_carMotionData: array[0..21] of TCarMotionData;  // Data for all cars on track
  end;

  TMarshalZone = packed record
    m_zoneStart: Single;                // Fraction (0..1) of way through the lap the marshal zone starts
    m_zoneFlag: Int8;                   // -1 = invalid/unknown, 0 = none, 1 = green, 2 = blue, 3 = yellow
  end;

  TWeatherForecastSample = packed record
    m_sessionType: UInt8;               // 0 = unknown, 1 = P1, 2 = P2, 3 = P3, 4 = Short P, 5 = Q1
                                        // 6 = Q2, 7 = Q3, 8 = Short Q, 9 = OSQ, 10 = R, 11 = R2
                                        // 12 = R3, 13 = Time Trial
    m_timeOffset: UInt8;                // Time in minutes the forecast is for
    m_weather: UInt8;                   // Weather - 0 = clear, 1 = light cloud, 2 = overcast
                                        // 3 = light rain, 4 = heavy rain, 5 = storm
    m_trackTemperature: Int8;           // Track temp. in degrees Celsius
    m_trackTemperatureChange: Int8;     // Track temp. change – 0 = up, 1 = down, 2 = no change
    m_airTemperature: Int8;             // Air temp. in degrees celsius
    m_airTemperatureChange: Int8;       // Air temp. change – 0 = up, 1 = down, 2 = no change
    m_rainPercentage: UInt8;            // Rain percentage (0-100)
  end;

  TPacketSessionData = packed record
    m_header: TPacketHeader;                        // Header
    m_weather: UInt8;              	                // Weather - 0 = clear, 1 = light cloud, 2 = overcast
                                                    // 3 = light rain, 4 = heavy rain, 5 = storm
    m_trackTemperature: Int8;    	                  // Track temp. in degrees celsius
    m_airTemperature: Int8;      	                  // Air temp. in degrees celsius
    m_totalLaps: UInt8;           	                // Total number of laps in this race
    m_trackLength: UInt16;           	              // Track length in metres
    m_sessionType: UInt8;         	                // 0 = unknown, 1 = P1, 2 = P2, 3 = P3, 4 = Short P
                                                    // 5 = Q1, 6 = Q2, 7 = Q3, 8 = Short Q, 9 = OSQ
                                                    // 10 = R, 11 = R2, 12 = R3, 13 = Time Trial
    m_trackId: Int8;         		                    // -1 for unknown, see appendix
    m_formula: UInt8;                  	            // Formula, 0 = F1 Modern, 1 = F1 Classic, 2 = F2,
                                                    // 3 = F1 Generic, 4 = Beta, 5 = Supercars
                                                    // 6 = Esports, 7 = F2 2021
    m_sessionTimeLeft: UInt16;    	                // Time left in session in seconds
    m_sessionDuration: UInt16;     	                // Session duration in seconds
    m_pitSpeedLimit: UInt8;      	                  // Pit speed limit in kilometres per hour
    m_gamePaused: UInt8;                            // Whether the game is paused – network game only
    m_isSpectating: UInt8;        	                // Whether the player is spectating
    m_spectatorCarIndex: UInt8;  	                  // Index of the car being spectated
    m_sliProNativeSupport: UInt8;	                  // SLI Pro support, 0 = inactive, 1 = active
    m_numMarshalZones: UInt8;         	            // Number of marshal zones to follow
    m_marshalZones: array[0..20] of TMarshalZone;   // List of marshal zones – max 21
    m_safetyCarStatus: UInt8;                       // 0 = no safety car, 1 = full
                                                    // 2 = virtual, 3 = formation lap
    m_networkGame: UInt8;                           // 0 = offline, 1 = online
    m_numWeatherForecastSamples: UInt8;             // Number of weather samples to follow
    m_weatherForecastSamples: array[0..55] of TWeatherForecastSample;   // Array of weather forecast samples
    m_forecastAccuracy: UInt8;                      // 0 = Perfect, 1 = Approximate
    m_aiDifficulty: UInt8;                          // AI Difficulty rating – 0-110
    m_seasonLinkIdentifier: UInt32;                 // Identifier for season - persists across saves
    m_weekendLinkIdentifier: UInt32;                // Identifier for weekend - persists across saves
    m_sessionLinkIdentifier: UInt32;                // Identifier for session - persists across saves
    m_pitStopWindowIdealLap: UInt8;                 // Ideal lap to pit on for current strategy (player)
    m_pitStopWindowLatestLap: UInt8;                // Latest lap to pit on for current strategy (player)
    m_pitStopRejoinPosition: UInt8;                 // Predicted position to rejoin at (player)
    m_steeringAssist: UInt8;                        // 0 = off, 1 = on
    m_brakingAssist: UInt8;                         // 0 = off, 1 = low, 2 = medium, 3 = high
    m_gearboxAssist: UInt8;                         // 1 = manual, 2 = manual & suggested gear, 3 = auto
    m_pitAssist: UInt8;                             // 0 = off, 1 = on
    m_pitReleaseAssist: UInt8;                      // 0 = off, 1 = on
    m_ERSAssist: UInt8;                             // 0 = off, 1 = on
    m_DRSAssist: UInt8;                             // 0 = off, 1 = on
    m_dynamicRacingLine: UInt8;                     // 0 = off, 1 = corners only, 2 = full
    m_dynamicRacingLineType: UInt8;                 // 0 = 2D, 1 = 3D
    m_gameMode: UInt8;                              // Game mode id - see appendix
    m_ruleSet: UInt8;                               // Ruleset - see appendix
    m_timeOfDay: UInt32;                            // Local time of day - minutes since midnight
    m_sessionLength: UInt8;                         // 0 = None, 2 = Very Short, 3 = Short, 4 = Medium
                                                    // 5 = Medium Long, 6 = Long, 7 = Full
    m_speedUnitsLeadPlayer: UInt8;                  // 0 = MPH, 1 = KPH
    m_temperatureUnitsLeadPlayer: UInt8;            // 0 = Celsius, 1 = Fahrenheit
    m_speedUnitsSecondaryPlayer: UInt8;             // 0 = MPH, 1 = KPH
    m_temperatureUnitsSecondaryPlayer: UInt8;       // 0 = Celsius, 1 = Fahrenheit
    m_numSafetyCarPeriods: UInt8;                   // Number of safety cars called during session
    m_numVirtualSafetyCarPeriods: UInt8;            // Number of virtual safety cars called
    m_numRedFlagPeriods: UInt8;                     // Number of red flags called during session
  end;

  TLapData = packed record
    m_lastLapTimeInMS: UInt32;	       	    // Last lap time in milliseconds
    m_currentLapTimeInMS: UInt32; 	        // Current time around the lap in milliseconds
    m_sector1TimeInMS: UInt16;              // Sector 1 time in milliseconds
    m_sector1TimeMinutes: UInt8;            // Sector 1 whole minute part
    m_sector2TimeInMS: UInt16;              // Sector 2 time in milliseconds
    m_sector2TimeMinutes: UInt8;            // Sector 2 whole minute part
    m_deltaToCarInFrontInMS: UInt16;        // Time delta to car in front in milliseconds
    m_deltaToRaceLeaderInMS: UInt16;        // Time delta to race leader in milliseconds
    m_lapDistance: Single;		              // Distance vehicle is around current lap in metres – could
                                            // be negative if line hasn’t been crossed yet
    m_totalDistance: Single;		            // Total distance travelled in session in metres – could
                                            // be negative if line hasn’t been crossed yet
    m_safetyCarDelta: Single;               // Delta in seconds for safety car
    m_carPosition: UInt8;   	              // Car race position
    m_currentLapNum: UInt8;		              // Current lap number
    m_pitStatus: UInt8;            	        // 0 = none, 1 = pitting, 2 = in pit area
    m_numPitStops: UInt8;            	      // Number of pit stops taken in this race
    m_sector: UInt8;               	        // 0 = sector1, 1 = sector2, 2 = sector3
    m_currentLapInvalid: UInt8;    	        // Current lap invalid - 0 = valid, 1 = invalid
    m_penalties: UInt8;            	        // Accumulated time penalties in seconds to be added
    m_totalWarnings: UInt8;                 // Accumulated number of warnings issued
    m_cornerCuttingWarnings: UInt8;         // Accumulated number of corner cutting warnings issued
    m_numUnservedDriveThroughPens: UInt8;   // Num drive through pens left to serve
    m_numUnservedStopGoPens: UInt8;         // Num stop go pens left to serve
    m_gridPosition: UInt8;         	        // Grid position the vehicle started the race in
    m_driverStatus: UInt8;         	        // Status of driver - 0 = in garage, 1 = flying lap
                                            // 2 = in lap, 3 = out lap, 4 = on track
    m_resultStatus: UInt8;                  // Result status - 0 = invalid, 1 = inactive, 2 = active
                                            // 3 = finished, 4 = didnotfinish, 5 = disqualified
                                            // 6 = not classified, 7 = retired
    m_pitLaneTimerActive: UInt8;     	      // Pit lane timing, 0 = inactive, 1 = active
    m_pitLaneTimeInLaneInMS: UInt16;   	    // If active, the current time spent in the pit lane in ms
    m_pitStopTimerInMS: UInt16;        	    // Time of the actual pit stop in ms
    m_pitStopShouldServePen: UInt8;   	    // Whether the car should serve a penalty at this stop
  end;

  TPacketLapData = packed record
    m_header: TPacketHeader;                // Header
    m_lapData: array[0..21] of TLapData;    // Lap data for all cars on track
    m_timeTrialPBCarIdx: UInt8; 	          // Index of Personal Best car in time trial (255 if invalid)
    m_timeTrialRivalCarIdx: UInt8; 	        // Index of Rival car in time trial (255 if invalid)
  end;

  TPacketEventData = packed record
    m_header: TPacketHeader;                // Header
    case m_eventStringCode: UInt32 of   	  // Event string code, see below
      $53535441:
        (vehicleIdxFastestLap: UInt8;
        lapTime: Single);
      1:
        (vehicleIdxRetirement: UInt8);
      2:
        (vehicleIdxTeamMateInPits: UInt8);
      3:
        (vehicleIdxRaceWinner: UInt8);
      4:
        (penaltyType: UInt8;
        infringementType: UInt8;
        vehicleIdx: UInt8;
        otherVehicleIdx: UInt8;
        time: UInt8;
        lapNum: UInt8;
        placesGained: UInt8);
      5:
        (vehicleIdxSpeedTrap: UInt8;
        speed: Single;
        isOverallFastestInSession: UInt8;
        isDriverFastestInSession: UInt8;
        fastestVehicleIdxInSession: UInt8;
        fastestSpeedInSession: Single);
      6:
        (numLights: UInt8);
      7:
        (vehicleIdxDriveThroughPenaltyServed: UInt8);
      8:
        (vehicleIdxStopGoPenaltyServed: UInt8);
      9:
        (flashbackFrameIdentifier: UInt32;
        flashbackSessionTime: Single);
      10:
        (buttonStatus: UInt32);
      11:
        (overtakingVehicleIdx: UInt8;
        beingOvertakenVehicleIdx: UInt8);   // Event details - should be interpreted differently
                                            // for each type
  end;

  TParticipantData = packed record
    m_aiControlled: UInt8;                // Whether the vehicle is AI (1) or Human (0) controlled
    m_driverId: UInt8;	                  // Driver id - see appendix, 255 if network human
    m_networkId: UInt8;	                  // Network id – unique identifier for network players
    m_teamId: UInt8;                      // Team id - see appendix
    m_myTeam: UInt8;                      // My team flag – 1 = My Team, 0 = otherwise
    m_raceNumber: UInt8;                  // Race number of the car
    m_nationality: UInt8;                 // Nationality of the driver
    m_name: array[0..47] of UTF8Char;     // Name of participant in UTF-8 format – null terminated
                                          // Will be truncated with … (U+2026) if too long
    m_yourTelemetry: UInt8;               // The player's UDP setting, 0 = restricted, 1 = public
    m_showOnlineNames: UInt8;             // The player's show online names setting, 0 = off, 1 = on
    m_platform: UInt8;                    // 1 = Steam, 3 = PlayStation, 4 = Xbox, 6 = Origin, 255 = unknown
  end;

  TPacketParticipantsData = packed record
    m_header: TPacketHeader;              // Header
    m_numActiveCars: UInt8;	              // Number of active cars in the data – should match number of
                                          // cars on HUD
    m_participants: array[0..21] of TParticipantData;
  end;

  TCarSetupData = packed record
    m_frontWing: UInt8;                   // Front wing aero
    m_rearWing: UInt8;                    // Rear wing aero
    m_onThrottle: UInt8;                  // Differential adjustment on throttle (percentage)
    m_offThrottle: UInt8;                 // Differential adjustment off throttle (percentage)
    m_frontCamber: Single;                // Front camber angle (suspension geometry)
    m_rearCamber: Single;                 // Rear camber angle (suspension geometry)
    m_frontToe: Single;                   // Front toe angle (suspension geometry)
    m_rearToe: Single;                    // Rear toe angle (suspension geometry)
    m_frontSuspension: UInt8;             // Front suspension
    m_rearSuspension: UInt8;              // Rear suspension
    m_frontAntiRollBar: UInt8;            // Front anti-roll bar
    m_rearAntiRollBar: UInt8;             // Front anti-roll bar
    m_frontSuspensionHeight: UInt8;       // Front ride height
    m_rearSuspensionHeight: UInt8;        // Rear ride height
    m_brakePressure: UInt8;               // Brake pressure (percentage)
    m_brakeBias: UInt8;                   // Brake bias (percentage)
    m_rearLeftTyrePressure: Single;       // Rear left tyre pressure (PSI)
    m_rearRightTyrePressure: Single;      // Rear right tyre pressure (PSI)
    m_frontLeftTyrePressure: Single;      // Front left tyre pressure (PSI)
    m_frontRightTyrePressure: Single;     // Front right tyre pressure (PSI)
    m_ballast: UInt8;                     // Ballast
    m_fuelLoad: Single;                   // Fuel load
  end;

  TPacketCarSetupData = packed record
    m_header: TPacketHeader;              // Header
    m_carSetups: array[0..21] of TCarSetupData;
  end;

  TCarTelemetryData = packed record
    m_speed: UInt16;                                  // Speed of car in kilometres per hour
    m_throttle: Single;                               // Amount of throttle applied (0.0 to 1.0)
    m_steer: Single;                                  // Steering (-1.0 (full lock left) to 1.0 (full lock right))
    m_brake: Single;                                  // Amount of brake applied (0.0 to 1.0)
    m_clutch: UInt8;                                  // Amount of clutch applied (0 to 100)
    m_gear: Int8;                                     // Gear selected (1-8, N=0, R=-1)
    m_engineRPM: UInt16;                              // Engine RPM
    m_drs: UInt8;                                     // 0 = off, 1 = on
    m_revLightsPercent: UInt8;                        // Rev lights indicator (percentage)
    m_revLightsBitValue: UInt16;                      // Rev lights (bit 0 = leftmost LED, bit 14 = rightmost LED)
    m_brakesTemperature: array[0..3] of UInt16;       // Brakes temperature (celsius)
    m_tyresSurfaceTemperature: array[0..3] of UInt8;  // Tyres surface temperature (celsius)
    m_tyresInnerTemperature: array[0..3] of UInt8;    // Tyres inner temperature (celsius)
    m_engineTemperature: UInt16;                      // Engine temperature (celsius)
    m_tyresPressure: array[0..3] of Single;           // Tyres pressure (PSI)
    m_surfaceType: array[0..3] of UInt8;              // Driving surface, see appendices
  end;

  TPacketCarTelemetryData = packed record
    m_header: TPacketHeader;	                        // Header
    m_carTelemetryData: array[0..21] of TCarTelemetryData;
    m_mfdPanelIndex: UInt8;                           // Index of MFD panel open - 255 = MFD closed
                                                      // Single player, race – 0 = Car setup, 1 = Pits
                                                      // 2 = Damage, 3 =  Engine, 4 = Temperatures
                                                      // May vary depending on game mode
    m_mfdPanelIndexSecondaryPlayer: UInt8;            // See above
    m_suggestedGear: Int8;                            // Suggested gear for the player (1-8)
                                                      // 0 if no gear suggested
  end;

  TCarStatusData = packed record
    m_tractionControl: UInt8;           // Traction control - 0 = off, 1 = medium, 2 = full
    m_antiLockBrakes: UInt8;            // 0 (off) - 1 (on)
    m_fuelMix: UInt8;                   // Fuel mix - 0 = lean, 1 = standard, 2 = rich, 3 = max
    m_frontBrakeBias: UInt8;            // Front brake bias (percentage)
    m_pitLimiterStatus: UInt8;          // Pit limiter status - 0 = off, 1 = on
    m_fuelInTank: Single;               // Current fuel mass
    m_fuelCapacity: Single;             // Fuel capacity
    m_fuelRemainingLaps: Single;        // Fuel remaining in terms of laps (value on MFD)
    m_maxRPM: UInt16;                   // Cars max RPM, point of rev limiter
    m_idleRPM: UInt16;                  // Cars idle RPM
    m_maxGears: UInt8;                  // Maximum number of gears
    m_drsAllowed: UInt8;                // 0 = not allowed, 1 = allowed
    m_drsActivationDistance: UInt16;    // 0 = DRS not available, non-zero - DRS will be available
                                        // in [X] metres
    m_actualTyreCompound: UInt8;	      // F1 Modern - 16 = C5, 17 = C4, 18 = C3, 19 = C2, 20 = C1
                                        // 21 = C0, 7 = inter, 8 = wet
                                        // F1 Classic - 9 = dry, 10 = wet
                                        // F2 – 11 = super soft, 12 = soft, 13 = medium, 14 = hard
                                        // 15 = wet
    m_visualTyreCompound: UInt8;        // F1 visual (can be different from actual compound)
                                        // 16 = soft, 17 = medium, 18 = hard, 7 = inter, 8 = wet
                                        // F1 Classic – same as above
                                        // F2 ‘19, 15 = wet, 19 – super soft, 20 = soft
                                        // 21 = medium , 22 = hard
    m_tyresAgeLaps: UInt8;              // Age in laps of the current set of tyres
    m_vehicleFiaFlags: Int8;	          // -1 = invalid/unknown, 0 = none, 1 = green
                                        // 2 = blue, 3 = yellow
    m_enginePowerICE: Single;           // Engine power output of ICE (W)
    m_enginePowerMGUK: Single;          // Engine power output of MGU-K (W)
    m_ersStoreEnergy: Single;           // ERS energy store in Joules
    m_ersDeployMode: UInt8;             // ERS deployment mode, 0 = none, 1 = medium
                                        // 2 = hotlap, 3 = overtake
    m_ersHarvestedThisLapMGUK: Single;  // ERS energy harvested this lap by MGU-K
    m_ersHarvestedThisLapMGUH: Single;  // ERS energy harvested this lap by MGU-H
    m_ersDeployedThisLap: Single;       // ERS energy deployed this lap
    m_networkPaused: UInt8;             // Whether the car is paused in a network game
  end;

  TPacketCarStatusData = packed record
    m_header: TPacketHeader;	          // Header
    m_carStatusData: array[0..21] of TCarStatusData;
  end;

  TFinalClassificationData = packed record
    m_position: UInt8;                          // Finishing position
    m_numLaps: UInt8;                           // Number of laps completed
    m_gridPosition: UInt8;                      // Grid position of the car
    m_points: UInt8;                            // Number of points scored
    m_numPitStops: UInt8;                       // Number of pit stops made
    m_resultStatus: UInt8;                      // Result status - 0 = invalid, 1 = inactive, 2 = active
                                                // 3 = finished, 4 = didnotfinish, 5 = disqualified
                                                // 6 = not classified, 7 = retired
    m_bestLapTimeInMS: UInt32;                  // Best lap time of the session in milliseconds
    m_totalRaceTime: Double;                    // Total race time in seconds without penalties
    m_penaltiesTime: UInt8;                     // Total penalties accumulated in seconds
    m_numPenalties: UInt8;                      // Number of penalties applied to this driver
    m_numTyreStints: UInt8;                     // Number of tyres stints up to maximum
    m_tyreStintsActual: array[0..7] of UInt8;   // Actual tyres used by this driver
    m_tyreStintsVisual: array[0..7] of UInt8;   // Visual tyres used by this driver
    m_tyreStintsEndLaps: array[0..7] of UInt8;  // The lap number stints end on
  end;

  TPacketFinalClassificationData = packed record
    m_header: TPacketHeader;                    // Header
    m_numCars: UInt8;                           // Number of cars in the final classification
    m_classificationData: array[0..21] of TFinalClassificationData;
  end;

  TLobbyInfoData = packed record
    m_aiControlled: UInt8;              // Whether the vehicle is AI (1) or Human (0) controlled
    m_teamId: UInt8;                    // Team id - see appendix (255 if no team currently selected)
    m_nationality: UInt8;               // Nationality of the driver
    m_platform: UInt8;                  // 1 = Steam, 3 = PlayStation, 4 = Xbox, 6 = Origin, 255 = unknown
    m_name: array[0..47] of UTF8Char;   // Name of participant in UTF-8 format – null terminated
                                        // Will be truncated with ... (U+2026) if too long
    m_carNumber: UInt8;                 // Car number of the player
    m_readyStatus: UInt8;               // 0 = not ready, 1 = ready, 2 = spectating
  end;

  TPacketLobbyInfoData = packed record
    m_header: TPacketHeader;            // Header
    m_numPlayers: UInt8;                // Number of players in the lobby data
    m_lobbyPlayers: array[0..21] of TLobbyInfoData;
  end;

  TCarDamageData = packed record
    m_tyresWear: array[0..3] of Single;        // Tyre wear (percentage)
    m_tyresDamage: array[0..3] of UInt8;       // Tyre damage (percentage)
    m_brakesDamage: array[0..3] of UInt8;      // Brakes damage (percentage)
    m_frontLeftWingDamage: UInt8;              // Front left wing damage (percentage)
    m_frontRightWingDamage: UInt8;             // Front right wing damage (percentage)
    m_rearWingDamage: UInt8;                   // Rear wing damage (percentage)
    m_floorDamage: UInt8;                      // Floor damage (percentage)
    m_diffuserDamage: UInt8;                   // Diffuser damage (percentage)
    m_sidepodDamage: UInt8;                    // Sidepod damage (percentage)
    m_drsFault: UInt8;                         // Indicator for DRS fault, 0 = OK, 1 = fault
    m_ersFault: UInt8;                         // Indicator for ERS fault, 0 = OK, 1 = fault
    m_gearBoxDamage: UInt8;                    // Gear box damage (percentage)
    m_engineDamage: UInt8;                     // Engine damage (percentage)
    m_engineMGUHWear: UInt8;                   // Engine wear MGU-H (percentage)
    m_engineESWear: UInt8;                     // Engine wear ES (percentage)
    m_engineCEWear: UInt8;                     // Engine wear CE (percentage)
    m_engineICEWear: UInt8;                    // Engine wear ICE (percentage)
    m_engineMGUKWear: UInt8;                   // Engine wear MGU-K (percentage)
    m_engineTCWear: UInt8;                     // Engine wear TC (percentage)
    m_engineBlown: UInt8;                      // Engine blown, 0 = OK, 1 = fault
    m_engineSeized: UInt8;                     // Engine seized, 0 = OK, 1 = fault
  end;

  TPacketCarDamageData = packed record
    m_header: TPacketHeader;               // Header
    m_carDamageData: array[0..21] of TCarDamageData;
  end;

  TLapHistoryData = packed record
    m_lapTimeInMS: UInt32;            // Lap time in milliseconds
    m_sector1TimeInMS: UInt16;        // Sector 1 time in milliseconds
    m_sector1TimeMinutes: UInt8;      // Sector 1 whole minute part
    m_sector2TimeInMS: UInt16;        // Sector 2 time in milliseconds
    m_sector2TimeMinutes: UInt8;      // Sector 2 whole minute part
    m_sector3TimeInMS: UInt16;        // Sector 3 time in milliseconds
    m_sector3TimeMinutes: UInt8;      // Sector 3 whole minute part
    m_lapValidBitFlags: UInt8;        // 0x01 bit set-lap valid,      0x02 bit set-sector 1 valid
                                      // 0x04 bit set-sector 2 valid, 0x08 bit set-sector 3 valid
  end;

  TTyreStintHistoryData = packed record
    m_endLap: UInt8;                  // Lap the tyre usage ends on (255 of current tyre)
    m_tyreActualCompound: UInt8;      // Actual tyres used by this driver
    m_tyreVisualCompound: UInt8;      // Visual tyres used by this driver
  end;

  TPacketSessionHistoryData = packed record
    m_header: TPacketHeader;                            // Header
    m_carIdx: UInt8;                                    // Index of the car this lap data relates to
    m_numLaps: UInt8;                                   // Num laps in the data (including current partial lap)
    m_numTyreStints: UInt8;                             // Number of tyre stints in the data
    m_bestLapTimeLapNum: UInt8;                         // Lap the best lap time was achieved on
    m_bestSector1LapNum: UInt8;                         // Lap the best Sector 1 time was achieved on
    m_bestSector2LapNum: UInt8;                         // Lap the best Sector 2 time was achieved on
    m_bestSector3LapNum: UInt8;                         // Lap the best Sector 3 time was achieved on
    m_lapHistoryData: array[0..99] of TLapHistoryData;	  // 100 laps of data max
    m_tyreStintsHistoryData: array[0..7] of TTyreStintHistoryData;
  end;

  TTyreSetData = packed record
    m_actualTyreCompound: UInt8;    // Actual tyre compound used
    m_visualTyreCompound: UInt8;    // Visual tyre compound used
    m_wear: UInt8;                  // Tyre wear (percentage)
    m_available: UInt8;             // Whether this set is currently available
    m_recommendedSession: UInt8;    // Recommended session for tyre set
    m_lifeSpan: UInt8;              // Laps left in this tyre set
    m_usableLife: UInt8;            // Max number of laps recommended for this compound
    m_lapDeltaTime: Int16;          // Lap delta time in milliseconds compared to fitted set
    m_fitted: UInt8;                // Whether the set is fitted or not
  end;

  TPacketTyreSetsData = packed record
    m_header: TPacketHeader;                      // Header
    m_carIdx: UInt8;                              // Index of the car this data relates to
    m_tyreSetData: array[0..19] of TTyreSetData;	// 13 (dry) + 7 (wet)
    m_fittedIdx: UInt8;                           // Index into array of fitted tyre
  end;

  TPacketMotionExData = packed record
    m_header: TPacketHeader;                        	// Header
                                                      // Extra player car ONLY data
    m_suspensionPosition: array[0..3] of Single;      // Note: All wheel arrays have the following order:
    m_suspensionVelocity: array[0..3] of Single;      // RL, RR, FL, FR
    m_suspensionAcceleration: array[0..3] of Single;  // RL, RR, FL, FR
    m_wheelSpeed: array[0..3] of Single;           	  // Speed of each wheel
    m_wheelSlipRatio: array[0..3] of Single;          // Slip ratio for each wheel
    m_wheelSlipAngle: array[0..3] of Single;          // Slip angles for each wheel
    m_wheelLatForce: array[0..3] of Single;           // Lateral forces for each wheel
    m_wheelLongForce: array[0..3] of Single;          // Longitudinal forces for each wheel
    m_heightOfCOGAboveGround: Single;                 // Height of centre of gravity above ground
    m_localVelocityX: Single;         	              // Velocity in local space – metres/s
    m_localVelocityY: Single;         	              // Velocity in local space
    m_localVelocityZ: Single;         	              // Velocity in local space
    m_angularVelocityX: Single;		                    // Angular velocity x-component – radians/s
    m_angularVelocityY: Single;                       // Angular velocity y-component
    m_angularVelocityZ: Single;                       // Angular velocity z-component
    m_angularAccelerationX: Single;                   // Angular acceleration x-component – radians/s/s
    m_angularAccelerationY: Single;	                  // Angular acceleration y-component
    m_angularAccelerationZ: Single;                   // Angular acceleration z-component
    m_frontWheelsAngle: Single;                       // Current front wheels angle in radians
    m_wheelVertForce: array[0..3] of Single;          // Vertical forces for each wheel
  end;

implementation

end.
