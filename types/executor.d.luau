declare Drawing: any
declare cloneref: (object: any) -> any
declare gethui: () -> Instance
declare compareinstances: (a: any, b: any) -> boolean
declare identifyexecutor: () -> (string, string)
declare LPH_NO_VIRTUALIZE: <T>(fn: T) -> T
declare LPH_OBFUSCATED: boolean?
-- luraph replaces a call to this with its own bail out; no macro outside a protected build, so antitamper.luau stubs it
declare LPH_CRASH: () -> ()
declare LPH_PRECHECK: (check: () -> { number }, expected: { number }) -> ()
declare isfunctionhooked: any
declare ishooked: any
declare is_function_hooked: any
-- folded by scripts/bundle.luau: true in free, false in paid, nil unbundled (behaves as paid)
declare SOTTORO_FREE: boolean?
declare SOTTORO_DEV: boolean?
declare SOTTORO_PART: (string | false)?
declare SOTTORO_MAIN: boolean?
declare LRM_INIT_SCRIPT: (fn: () -> ()) -> ()
declare LRM_LinkedDiscordID: any
declare gethwid: any
declare script_key: string?
declare request: any
declare http_request: any
declare syn: any
declare fluxus: any
declare queue_on_teleport: any
declare queueonteleport: any
declare messageboxasync: any
declare messagebox: any
declare setclipboard: (text: string) -> ()
declare getgenv: () -> { [string]: any }
declare getrenv: () -> { [string]: any }
declare getloadedmodules: () -> { any }
declare clonefunction: <T>(fn: T) -> T
-- an executor carries at most one (antitamper.luau)
declare isfunctionhooked: ((fn: any) -> any)?
declare ishooked: ((fn: any) -> any)?
declare is_function_hooked: ((fn: any) -> any)?
declare isfile: (path: string) -> boolean
declare writefile: (path: string, contents: string) -> ()
declare appendfile: (path: string, contents: string) -> ()
declare makefolder: (path: string) -> ()
declare getcustomasset: (path: string, noCache: boolean?) -> string
declare mousemoverel: (x: number, y: number) -> ()
declare mouse1press: () -> ()
declare mouse1release: () -> ()
declare getgc: (includeTables: boolean?) -> { any }
declare getcallingscript: any
declare getinfo: any
declare readfile: (path: string) -> string
declare isfolder: (path: string) -> boolean
declare getconnections: any
declare firetouchinterest: any
declare firesignal: any
declare setfpscap: any
declare getfpscap: any
declare setthreadidentity: any
declare getthreadidentity: any
declare setthreadcontext: any
declare getthreadcontext: any
declare fireproximityprompt: any
declare fireclickdetector: any
declare getcallbackvalue: (object: any, property: string) -> any
declare getscriptbytecode: any
declare raknet: any
declare sethiddenproperty: any
declare delfile: any
declare listfiles: (path: string) -> { string }
declare getrawmetatable: (object: any) -> any
declare setreadonly: (target: any, readonly: boolean) -> ()
declare newcclosure: <T>(fn: T) -> T
declare getnamecallmethod: () -> string
declare checkcaller: () -> boolean
declare isrbxactive: () -> boolean
declare mouse1click: () -> ()
declare mouse1press: () -> ()
declare mouse1release: () -> ()
declare keypress: (key: number) -> ()
declare keyrelease: (key: number) -> ()
declare hookmetamethod: any
declare hookfunction: any
declare restorefunction: any
declare islclosure: (fn: any) -> boolean
declare isreadonly: ((target: any) -> boolean)?
declare getsenv: any
declare getupvalues: any
declare setupvalue: any
declare gethiddenproperty: any
declare isnetworkowner: any
declare WebSocket: any
declare websocket: any
declare getactors: () -> { any }
declare run_on_actor: (actor: any, source: string, ...any) -> ()
declare create_comm_channel: () -> (number, any)
