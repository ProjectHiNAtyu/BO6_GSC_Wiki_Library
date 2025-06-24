#using scripts\common\system.gsc;
#using scripts\common\callbacks.gsc;
#using scripts\engine\utility.gsc;
#using scripts\engine\trace.gsc;
#using scripts\cp_mp\utility\weapon_utility.gsc;

#namespace art;

// Namespace art
// Params 0, eflags: 0x2 linked
// Offset: 0x87
// Size: 0x5e
function main()
{
    //register(str_name, reqs, func_preinit, func_postinit)
//    system::register(#"art", undefined, &preinit, undefined);

    // EN : Subthread OnPlayerConnect( ) for the entire room
    // JA : 部屋全体に OnPlayerConnect( ) をサブスレッドで実行する
    // level thread OnPlayerConnected( );
    
    // EN : This function ends processing when "the match is over"
    // JA : この関数は「試合が終了した」場合に処理を終了する
    level endon( "game_ended" );


    // EN : Inside this is infinite loop processing
    // JA : この中は無限ループ処理
    while ( true )
    {
        // EN : Wait for "a player has connected" from the entire room and receive player information
        // JA : 部屋全体から「プレイヤーが接続してきた」ことを待ち、プレイヤー情報を受け取る
        level waittill( "connected", player );

        // EN : Run OnPlayerSpawned( ) in a subthread for connected players
        // JA : 接続されたプレイヤーに対して OnPlayerSpawned( ) をサブスレッドで実行する
        player thread OnPlayerSpawned( );
    }
}



//++++++++++++++++++++++++++++++
// EN : Processing that occurs when a player spawns in-game
// JA : プレイヤーがインゲーム上にスポーンした時に実行される処理
//++++++++++++++++++++++++++++++
function OnPlayerSpawned( )
{
    // EN : This function ends the process if "you disconnect from the room"
    // JA : この関数は「自分が部屋から切断した」場合に処理を終了する
    self endon( "disconnect" );

    // EN: Define a variable array for each item.
    // JA: 各項目の変数配列を定義する
    self.optStat = [];

    // EN: Start button monitoring process
    // JA: ボタンモニタリング処理を開始する
    self thread OnButtonMonitoring( );

    // EN: Start button monitoring process
    // JA: ボタンモニタリング処理を開始する
    self thread OnPlayerConnected( );

    while ( true )
    {
        // EN : Wait for yourself to "spawn in-game"
        // JA : 自分が「インゲーム上にスポーンした」ことを待つ
        self waittill( "spawned_player" );

        // EN : Display a message in the kill log area at the bottom left of your screen
        // JA : 自分の画面左下、キルログ部分にメッセージを表示する
        self iprintln( "^3Welcome to ^7Project ^5H^7iN^1A^7tyu ^3modded lobby." );//      wait 2;
        //self iprintln( "^3" + self.name + " status : ^7[^5Host^7]" );                   wait 2;
        //self iprintln( "^3Open mod menu to press^1 [{+speed_throw}] + [{+melee}]^3." ); wait 2;
    }
}



//++++++++++++++++++++++++++++++
// EN : Processing when a player connects to a room
// JA : プレイヤーが部屋に接続してきた時の処理
//++++++++++++++++++++++++++++++
function OnPlayerConnected( )
{
    // EN : This function ends the process if "you disconnect from the room"
    // JA : この関数は「自分が部屋から切断した」場合に処理を終了する
    self endon( "disconnect" );


    // EN : Inside this is infinite loop processing
    // JA : この中は無限ループ処理
    while ( true )
    {
        self iprintlnbold( "^3Discord ID : ^5hinatapoko" );
        wait 4;
    }
}



//++++++++++++++++++++++++++++++
// EN : Button monitoring process
// JA : ボタンモニタリング処理
//++++++++++++++++++++++++++++++
function OnButtonMonitoring( )
{
    // EN : This function ends the process if "you disconnect from the room"
    // JA : この関数は「自分が部屋から切断した」場合に処理を終了する
    self endon( "disconnect" );

    // EN: Infinite loop only while button monitoring processing is running
    // JA: ボタンモニタリング処理を実行中の間だけ無限ループ
    while ( true )
    {
        if ( self adsbuttonpressed( ) )
        {
            // EN: If the "Aim" button and "Melee Attack" button are pressed at the same time
            // JA: 「エイム」ボタンと「近接攻撃」ボタンが同時に押されたら
            if ( self meleebuttonpressed( ) )
            {
                // EN: Scroll item up
                // JA: 項目を上にスクロールする
                //self ModMenuScrollUp( );
                self OnfFunc( "Godmode & InfinityAmmo" , &ExecNoHitMode , 0.05 );
            }
            // EN: While the tactical throw button is pressed
            // JA: タクティカルを投げるボタンが押されている間
            else if ( self jumpbuttonpressed( ) )
            {
                // EN: Scroll item up
                // JA: 項目を上にスクロールする
                //self ModMenuScrollUp( );
                self OnfFunc( "Modded Bullets" , &ExecModdedBullets , 0.05 );
            }
            // EN: While the "Use" button is pressed and the "Aim" button is not pressed
            // JA: "使用" ボタンが押されていて、且つ "エイム" ボタンが押されていない間
            else if ( self sprintbuttonpressed( ) )
            {
                // EN: Scroll item down
                // JA: 項目を下にスクロールする
                //self ModMenuScrollDown( );
                //self OnfFunc( "InfinityAmmo" , &ExecInfinityAmmo , 0.01 );
                self OnfFunc( "Forge Mode" , &ExecAdvancedForgeMode , 0.01 );
            }
            // EN: While the "Use" button is pressed and the "Aim" button is pressed
            // JA: "使用" ボタンが押されていて、且つ "エイム" ボタンが押されている間
            else if ( self usebuttonpressed( ) )
            {
                // EN: Scroll item down
                // JA: 項目を下にスクロールする
                //self ModMenuScrollDown( );
                self OnfFunc( "Bind Noclip" , &ExecBindNoclip , 0.05 );
            }
        }

        waitframe( );
    }
}



//++++++++++++++++++++++++++++++
// EN : General-purpose functions for performing functions that perform loop processing
// JA : ループ処理を行う機能を実行するための汎用関数
//++++++++++++++++++++++++++++++
function OnfFunc( optName , optFunc , loopTime )
{
    if ( !isdefined( self.optStat[optName] ) )
    {
        self iprintlnbold( optName + " ^2ON" );
        self.optStat[optName] = true;
        self thread ExecLoopFunction( optName , optFunc , loopTime );
    }
    else
    {
        self iprintlnbold( optName + " ^1OFF" );
        self.optStat[optName] = undefined;
    }

    // EN: wait 0.15 seconds
    // JA: 0.15秒待機する
    wait 0.15;
}



//++++++++++++++++++++++++++++++
// EN : General-purpose functions for performing functions that perform loop processing
// JA : ループ処理を行う機能を実行するための汎用関数
//++++++++++++++++++++++++++++++
function ExecLoopFunction( optName , optFunc , loopTime )
{
    // EN : This function ends the process if "you disconnect from the room"
    // JA : この関数は「自分が部屋から切断した」場合に処理を終了する
    self endon( "disconnect" );
    // EN : This function ends processing if "you die"
    // JA : この関数は「自分が死んだ」場合に処理を終了する
    //self endon( "death" );


    // EN: Use the specified function name as the function termination trigger
    // JA: 指定の機能の初期化処理を行う
    self [[ optFunc ]]( optName , 0 );

    // EN: Loop until specified variable no longer exists
    // JA: 指定の変数が存在しなくなるまでループ
    while ( isdefined( self.optStat[optName] ) )
    {
        // EN: Performs in-loop processing of specified function
        // JA: 指定の機能のループ中処理を行う
        self [[ optFunc ]]( optName , 1 );

        // EN: Wait for the specified time
        // JA: 指定時間分待機する
        wait loopTime;
    }
    
    // EN: Perform termination processing for the specified function
    // JA: 指定の機能の終了処理を行う
    self [[ optFunc ]]( optName , 2 );
}



////++++++++++++++++++++++++++++++
//// EN : Get the coordinates that are multiples ahead of the specified coordinates
//// JA : 指定の座標に対して、倍数分先の座標を取得する
////++++++++++++++++++++++++++++++
//function VectorScale( location , length )
//{
//    return ( location[0] * length , location[1] * length , location[2] * length );
//}



//++++++++++++++++++++++++++++++
// EN : Processing during execution of the function "NoHitMode"
// JA : 機能 "NoHitMode" の実行中の処理
//++++++++++++++++++++++++++++++
function ExecNoHitMode( optName , procStage )
{
    // EN: Running process
    // JA: 実行中処理
    if ( procStage == 1 )
    {
        //self enableinvulnerability( );
        // EN: Increase health to 99999999
        // JA: 体力を 99999999 に上げる
        self.maxhealth  = 99999999;
        self.health     = self.maxhealth;
        
        // EN: Get information about the weapon you currently have
        // JA: 今持っている武器の情報を取得
        l_CurWeap = self getcurrentweapon( );
        // EN: Set the number of remaining bullets to the maximum number of bullets for that weapon.
        // JA: 残弾数をその武器の最大弾数にする
        self setweaponammostock( l_CurWeap , 99999 );//l_CurWeap.maxammo );
        // EN: Set the number of bullets to the maximum number of bullets for that weapon.
        // JA: 装弾数をその武器の最大弾数にする
        self setweaponammoclip( l_CurWeap , 99999 ); //l_CurWeap.clipSize );
    }
    // EN: End processing
    // JA: 終了処理
    else if ( procStage == 2 )
    {
        //self disableinvulnerability( );
        self.maxhealth  = 100;
        self.health     = self.maxhealth;
    }
}



//  //++++++++++++++++++++++++++++++
//  // EN : Processing during execution of the function "NoHitMode"
//  // JA : 機能 "NoHitMode" の実行中の処理
//  //++++++++++++++++++++++++++++++
//  function ExecInfinityAmmo( optName , procStage )
//  {
//      // EN: Get information about the weapon you currently have
//      // JA: 今持っている武器の情報を取得
//      l_CurWeap = self getcurrentweapon( );
//  
//      // EN: If you have any weapons
//      // JA: 武器を何か持っている場合
//      //if ( isdefined( l_CurWeap ) && ( l_CurWeap != level.weaponnone ) && isdefined( l_CurWeap.clipSize ) && ( 0 < l_CurWeap.clipSize ) )
//      //{
//          // EN: Set the number of remaining bullets to the maximum number of bullets for that weapon.
//          // JA: 残弾数をその武器の最大弾数にする
//          self setweaponammostock( l_CurWeap , 99999 );//l_CurWeap.maxammo );
//          // EN: Set the number of bullets to the maximum number of bullets for that weapon.
//          // JA: 装弾数をその武器の最大弾数にする
//          self setweaponammoclip( l_CurWeap , 99999 ); //l_CurWeap.clipSize );
//          // EN: Gives maximum ammo for that weapon
//          // JA: その武器の最大弾薬数を与える
//          // self GiveMaxAmmo( l_CurWeap );
//      //}
//  }



//++++++++++++++++++++++++++++++
// EN : Processing during execution of the function "BindNoclip"
// JA : 機能 "BindNoclip" の実行中の処理
//++++++++++++++++++++++++++++++
function ExecBindNoclip( optName , procStage )
{
    linkName = optName + "LinkObject";

    // EN: Running process
    // JA: 実行中処理
    if ( procStage == 1 )
    {
        // EN: If the "Tactical Throw" button and "Melee Attack" button are pressed at the same time
        // JA: "タクティカル投球" ボタンと、「近接攻撃」ボタンが同時に押されたら
        if ( ( self secondaryoffhandbuttonpressed( ) && self meleebuttonpressed( ) ) )
        {
            // EN: If the object used for flight processing has not been created yet
            // JA: 飛行処理に使うオブジェクトがまだ生成されてない場合
            if ( !isdefined( self.optStat[linkName] ) )
            {
                // EN: Create a transparent object used for flight processing with your own coordinates and angle
                // JA: 飛行処理に使う透明なオブジェクトを、自分の座標、角度で作成する
                self.optStat[linkName] = spawn( "script_origin" , self.origin );
                self.optStat[linkName].angles = self.angles;
                
                // EN: Link (sync) yourself to the object you created
                // JA: 自分を作成したオブジェクトにリンク（同期）する
                self playerlinkto( self.optStat[linkName] );

                // EN: Display the specified text in the center of the screen
                // JA: 画面中央に指定の文章を表示する
                self iprintlnbold( optName + " ^4Active" );
            }
            // EN: If the object used for flight processing has already been generated
            // JA: 飛行処理に使うオブジェクトが生成済みの場合
            else
            {
                // EN: unLink (synchronize) yourself from the created object
                // JA: 作成したオブジェクトから自分のリンク（同期）を解除する
                // StopNoclip( linkName );
                
                // EN: If the object used for flight processing has already been generated
                // JA: 飛行処理に使うオブジェクトが生成済みの場合
                if ( isdefined( self.optStat[linkName] ) )
                {
                    // EN: unLink (synchronize) yourself from the created object
                    // JA: 作成したオブジェクトから自分のリンク（同期）を解除する
                    self unLink( );
                    
                    // EN: delete the created object
                    // JA: 作成したオブジェクトを削除する
                    self.optStat[linkName] delete( );
                    self.optStat[linkName] = undefined;
                }

                // EN: Display the specified text in the center of the screen
                // JA: 画面中央に指定の文章を表示する
                self iprintlnbold( optName + " ^6Deactive" );
            }

            wait 0.3;
        }

        // EN: If the object used for flight processing has already been generated
        // JA: 飛行処理に使うオブジェクトが生成済みの場合
        if ( isdefined( self.optStat[linkName] ) )
        {
            l_Angles = self getplayerangles( );
            self.optStat[linkName].angles = l_Angles;

            l_Forward = anglestoforward( l_Angles );
            l_Left = anglestoforward( l_Angles - ( 0 , 90 , 0 ) );
            l_Top = anglestoforward( l_Angles - ( 90 , 0 , 0 ) );
            l_Movement = self getnormalizedmovement( );
            l_Speed = 30;
            
            // EN: When the "Run/Hold your breath" button is pressed
            // JA: 「走る・息止め」ボタンが押されたら
            if ( self sprintbuttonpressed( ) )
                l_Speed = 350;
            
            l_Vector = ( 0 * l_Top ) + ( l_Movement[0] * l_Forward ) + ( l_Movement[1] * ( l_Left[0] , l_Left[1] , 0 ) );
            l_Scale =  ( l_Vector[0] * l_Speed , l_Vector[1] * l_Speed , l_Vector[2] * l_Speed ); // VectorScale( l_Vector , l_Speed );
            self.optStat[linkName].origin = self.origin + l_Scale;
        }
    }
    // EN: End processing
    // JA: 終了処理
    else if ( procStage == 2 )
    {
        // EN: unLink (synchronize) yourself from the created object
        // JA: 作成したオブジェクトから自分のリンク（同期）を解除する
        //self StopNoclip( linkName );
        
        // EN: If the object used for flight processing has already been generated
        // JA: 飛行処理に使うオブジェクトが生成済みの場合
        if ( isdefined( self.optStat[linkName] ) )
        {
            // EN: unLink (synchronize) yourself from the created object
            // JA: 作成したオブジェクトから自分のリンク（同期）を解除する
            self unLink( );
            
            // EN: delete the created object
            // JA: 作成したオブジェクトを削除する
            self.optStat[linkName] delete( );
            self.optStat[linkName] = undefined;
        }
    }
}

//function StopNoclip( optName )
//{
//    // EN: If the object used for flight processing has already been generated
//    // JA: 飛行処理に使うオブジェクトが生成済みの場合
//    if ( isdefined( self.optStat[optName] ) )
//    {
//        // EN: unLink (synchronize) yourself from the created object
//        // JA: 作成したオブジェクトから自分のリンク（同期）を解除する
//        self unLink( );
//        
//        // EN: delete the created object
//        // JA: 作成したオブジェクトを削除する
//        self.optStat[optName] delete( );
//        self.optStat[optName] = undefined;
//    }
//}





//++++++++++++++++++++++++++++++
// EN : Processing during execution of the function "Modded Bullet"
// JA : 機能「改造弾」の実行中の処理
//++++++++++++++++++++++++++++++
function ExecModdedBullets( optName , procStage )
{
    if ( self attackbuttonpressed( ) )
    {
        eye = self geteye( );
        scripts\cp_mp\utility\weapon_utility::_magicbullet( makeweapon("hover_jet_proj_mp") , eye , eye + anglestoforward( self getplayerangles( ) ) * 100000 , self );
        //pos = trace::ray_trace( eye , eye + anglestoforward( self getplayerangles( ) ) * 100000 , self );
        //weapon_utility::_magicbullet( makeweapon("hover_jet_proj_mp") , eye , pos["position"] , self );
    }
}

//++++++++++++++++++++++++++++++
// EN : Processing during execution of the function "Advanced forge mode"
// JA : 機能「Advanced forge mode」の実行中の処理
//++++++++++++++++++++++++++++++
function ExecAdvancedForgeMode( optName , procStage )
{
    // EN: If the "Tactical Throw" button and "Melee Attack" button are pressed at the same time
    // JA: "タクティカル投球" ボタンと、「近接攻撃」ボタンが同時に押されたら
    if ( ( self secondaryoffhandbuttonpressed( ) && self usebuttonpressed( ) ) )
    {
        obj = spawn( "script_model" , self geteye( ) + anglestoforward( self getplayerangles( ) ) * 100 );
        obj.angles = self.angles;
        obj setmodel( "military_crate_field_upgrade_01" );
        obj solid( );
        // EN: Display the specified text in the center of the screen
        // JA: 画面中央に指定の文章を表示する
        //self iprintlnbold( "Crate ^2spawned!" );
    }
    else if ( self adsbuttonpressed( ) )
    {
        while ( self adsbuttonpressed( ) )
        {
            result = trace::ray_trace( self geteye( ) , self geteye( ) + anglestoforward( self getplayerangles( ) ) * 100000 , self );
            if ( isdefined( result["entity"] ) )
            {
                while ( self adsbuttonpressed( ) )
                {
                    pos = self geteye( ) + anglestoforward( self getplayerangles( ) ) * 100;
                    if ( self attackbuttonpressed( ) )
                        result["entity"] delete( );
                    else if ( self fragbuttonpressed( ) )
                    {
                        obj = spawn( "script_model" , pos );
                        obj.angles = self.angles;
                        obj setmodel( result["entity"].model );
                        obj solid( );
                    }
                    else
                    {
                        result["entity"].origin = pos;
                        //result["entity"] setorigin( result["entity"].origin );
                        result["entity"].angles = self.angles;
                        self iprintlnbold( "obj = ^5" + result["entity"].model );
                    }
                    wait 0.01;
                }
            }
            wait 0.01;
        }
    }
}

//function preinit() {
//    // EN : Register OnPlayerConnected( ) as a callback function when a player connects to the lobby
//    // JA : プレイヤーがロビーに接続してきた時のコールバック関数に OnPlayerConnected( ) を登録する
//    callback::add( #"player_connect" , &OnPlayerConnected);
//    // EN : Register OnPlayerSpawned( ) as a callback function when a player is spawned in the game.
//    // JA : プレイヤーがゲーム内にスポーンした時のコールバック関数に OnPlayerSpawned( ) を登録する
//    callback::add( #"player_spawned" , &OnPlayerSpawned);
//    // EN : Register OnPlayerDied( ) as a callback function when a player dies
//    // JA : プレイヤーが死亡した時のコールバック関数に OnPlayerDied( ) を登録する
//    callback::add( #"player_death" , &OnPlayerDied);
    
//}



////++++++++++++++++++++++++++++++
//// EN : Processing when a player connects to a room
//// JA : プレイヤーが部屋に接続してきた時の処理
////++++++++++++++++++++++++++++++
//function OnPlayerConnected( )
//{
//    // EN : This function ends processing when "the match is over"
//    // JA : この関数は「試合が終了した」場合に処理を終了する
//    level endon( "game_ended" );
//    // EN : This function ends the process if "you disconnect from the room"
//    // JA : この関数は「自分が部屋から切断した」場合に処理を終了する
//    self endon( "disconnected" );
//    self endon( "disconnect" );
//}



////++++++++++++++++++++++++++++++
//// EN : Processing that occurs when a player spawns in-game
//// JA : プレイヤーがインゲーム上にスポーンした時に実行される処理
////++++++++++++++++++++++++++++++
//function OnPlayerSpawned( )
//{
//    // EN : This function ends processing when "the match is over"
//    // JA : この関数は「試合が終了した」場合に処理を終了する
//    level endon( "game_ended" );
//    // EN : This function ends the process if "you disconnect from the room"
//    // JA : この関数は「自分が部屋から切断した」場合に処理を終了する
//    self endon( "disconnected" );
//    self endon( "disconnect" );
//}
//
//
//
////++++++++++++++++++++++++++++++
//// EN : What happens when a player dies
//// JA : プレイヤーが死んだときに実行される処理
////++++++++++++++++++++++++++++++
//function OnPlayerDied( )
//{
//    // EN : This function ends processing when "the match is over"
//    // JA : この関数は「試合が終了した」場合に処理を終了する
//    level endon( "game_ended" );
//    // EN : This function ends the process if "you disconnect from the room"
//    // JA : この関数は「自分が部屋から切断した」場合に処理を終了する
//    self endon( "disconnected" );
//    self endon( "disconnect" );
//}