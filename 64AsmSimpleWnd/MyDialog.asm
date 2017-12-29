extern RegisterClassExA:proc
extern GetModuleHandleA:proc
extern CreateWindowExA:proc
extern ShowWindow:proc
extern UpdateWindow:proc
extern GetMessageA:proc
extern TranslateMessage:proc
extern DispatchMessageA:proc
extern ExitProcess:proc
extern PostQuitMessage:proc
extern DefWindowProcA:proc
extern DestroyWindow:proc
extern GetLastError:proc
extern MessageBoxA:proc

CS_VREDRAW         equ 1
CS_HREDRAW         equ 2
COLOR_ACTIVEBORDER equ 10
SW_SHOW            equ  5
WM_CLOSE           equ 10h
WM_DESTROY		   equ 0002h



includelib user32.lib
includelib kernel32.lib

.const
;__________________________const域Begin___________________________
;    UINT        cbSize;
;    /* Win 3.x */
;    UINT        style;
;    WNDPROC     lpfnWndProc;
;    int         cbClsExtra;
;    int         cbWndExtra;
;    HINSTANCE   hInstance;
;    HICON       hIcon;
;    HCURSOR     hCursor;
;    HBRUSH      hbrBackground;
;    LPCWSTR     lpszMenuName;
;    LPCWSTR     lpszClassName;
;    /* Win 4.0 */
;    HICON       hIconSm;
;} WNDCLASSEXW, *PWNDCLASSEXW, NEAR *NPWNDCLASSEXW, FAR *LPWNDCLASSEXW;

	WNDCLASSEX struct
		cbSize			dd	?
		style			dd	?
		lpfnWndProc		dq	?
		cbClsExtra		dd	?
		cbWndExtra		dd	?
		hInstance		dq	?
		hIcon			dq	?
		hCursor			dq	?
		hbrBackground	dq	?
		lpszMenuName	dq	?
		lpszClassName	dq	?
		hIconSm			dq	?
	WNDCLASSEX ends

    
    POINT struct
        x   dd  ?
        y   dd  ?
    POINT ends
	
	
	MSG struct
        hwnd            dq  ?
        message         dd  ?
        wParam          dq  ?
        lParam          dq  ?
        time            dd  ?
        pt              POINT <>
    MSG ends
;__________________________const域End___________________________


;__________________________const域End___________________________
.data
	g_Instance dd 0h
	wcex WNDCLASSEX <>
	g_MyWndClassName db	"sdfsdfsldfjl", 0h
	g_Title db "xxxxsdfsdfx", 0h
	g_Msg MSG <>
	hwndMain     dq 1
	;	int wmId, wmEvent;
	;	PAINTSTRUCT ps;
	;	HDC hdc;
;__________________________const域End___________________________


;__________________________code域Begin__________________________
.code
Main proc
	sub rsp, 60h
	
	; 填写窗口类结构体
	mov wcex.cbSize,		sizeof WNDCLASSEX
    mov r8d, CS_HREDRAW
    or  r8d, CS_VREDRAW
    mov wcex.style, r8d
	lea rax, MyWmdProc
    mov wcex.lpfnWndProc, rax   
	xor rax, rax
	mov wcex.cbClsExtra,	eax
	mov wcex.cbWndExtra,	eax
	xor rcx, rcx
	call GetModuleHandleA
	mov wcex.hInstance, rax
	xor rcx, rcx
	mov wcex.hIcon, rcx
	mov wcex.hCursor, rcx
	mov wcex.hbrBackground, 6
	mov wcex.lpszMenuName, rcx
	lea rax, g_MyWndClassName
	mov wcex.lpszClassName, rax
	mov wcex.hIconSm, rcx
	
	; 注册窗口类
	lea rcx, wcex
	call RegisterClassExA
	
	; 创建窗口
	xor ecx, ecx
	lea rdx, g_MyWndClassName
	lea r8, g_Title
	mov r9d,0CF0000h 
	xor rax, rax
	mov r11, wcex.hInstance
	mov [rsp+58h], rax
	mov [rsp+50h], r11
	mov [rsp+48h], rax
	mov [rsp+40h], rax
	mov	rax,80000000H
	xor rcx, rcx
	mov [rsp+38h], rcx
	mov [rsp+30h], rax
	mov [rsp+28h], rcx
	mov [rsp+20h], rax
	call CreateWindowExA
	cmp rax, 0
	jz _RET
	
	; 显示窗口
	mov [hwndMain], rax
    mov rcx, rax
    mov rdx, SW_SHOW
    call ShowWindow
	
	; 刷新窗口
	mov [hwndMain], rax
    mov rcx, rax
    call UpdateWindow
	
	
	;// 主消息循环: 
	;while (GetMessage(&msg, NULL, 0, 0))
	;{
	;		TranslateMessage(&msg);
	;		DispatchMessage(&msg);
	;}
_LOOP:
    lea rcx, g_Msg
    xor rdx, rdx
    xor r8, r8
    xor r9, r9
    call GetMessageA
	
    cmp rax, 0
    jz  _RET
	
	lea rcx, g_Msg
	call TranslateMessage
	
	lea rcx, g_Msg
	call DispatchMessageA
	jmp _LOOP

	_RET:
	add rsp, 60h
	ret
Main endp


; 窗口过程函数
MyWmdProc proc
	sub rsp, 28h
	cmp edx, WM_CLOSE
	jz CLOSE
	cmp edx, WM_DESTROY
	jz DESTROY
	jmp DEFAULT_PROC
	
	
CLOSE:
	call DestroyWindow
jmp PROC_RET
DESTROY:
	xor ecx, ecx
	call PostQuitMessage
jmp PROC_RET


DEFAULT_PROC:
	call DefWindowProcA
PROC_RET:
	add rsp, 28h
	ret
MyWmdProc endp
end