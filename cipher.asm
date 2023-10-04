IDEAL
MODEL small
STACK 100h
DATASEG
message db "all happy families resemble one another every unhappy family is unhappy in its own way all was confusion in the house of the oblonskys the wife had discovered that her husband was having an intrigue with a french governess who had been in "
message2 db "their employ and she declared that she could not live in the same house with him"
message3 db "this condition of things had lasted now three days and was causing deep discomfort not only to the husband" 
message4 db "and wife but also to all the members of the family and the domestics", "all the members of the family and the domestics felt that there was no sense in their living together and","that in any hotel people meeting casually had more mutual interests than they the members of the family","and the domestics of the house of oblonsky","the wife did not come out of her own rooms","the husband had not been at home for two days","the children were running over the whole house as if they were crazy","the english maid was angry with the housekeeper and wrote to a friend begging her to find her a new place","the head cook had departed the evening before just at dinner time","the kitchen maid and the coachman demanded their wages$"
letters db 26 dup(0)
key db 3 
CODESEG
KeyVal equ [bp + 8]
Text equ [bp + 6]
CipherType equ [bp + 4]
proc Cipher
	push bp
	mov bp, sp
	push ax
	push bx
	push cx 
	mov bx, Text; move text to base register
	mov cl, KeyVal
	push di
	mov di, CipherType
	cmp di, 0
	je LoopWord
	neg cl
	xor si, si
	LoopWord:
	mov al, [byte ptr bx + si]
	cmp al, "$"
	je Finish
	add al, cl
	mov [bx + si], al
	inc si
	jmp LoopWord
	Finish:
		pop di 
		pop cx 
		pop bx
		pop ax
		pop bp 
	ret 6
endp

String equ [ bp + 6]
datasegment equ [ bp + 4]
proc PrintStr
	push bp
	mov bp, sp
	push dx
	push ds
	mov ds, datasegment
	mov dx, String 
	mov ah, 9h
	int 21h
	pop ds
	pop dx 
	pop bp
	ret 4
endp

Text equ [bp + 4]
proc CountChar
	push bp
	mov bp, sp
	mov bx, Text
	xor si, si
	push ax 
	xor ah, ah 
	push bx
	LoopText:
	mov al, [byte ptr bx + si]
	cmp al, "$"
	je Finish2
	cmp al, " "
	je LoopText
	sub al, 60h ; add 1 becuase array index starts from zero
	push si 
	mov si, ax
	add [letters + si], 1
	pop si
	inc si
	jmp LoopText
	Finish2:
	pop ax
	pop bx
	pop bp
	ret 2
endp

Text equ [bp + 4]
proc FindLen
	push bp
	mov bp, sp
	mov bx, Text
	xor si, si
	xor ax, ax
	push dx 
	Count:
	mov dx, [bx + si] 
	cmp dx, "$"
	je Finish3
	inc si
	jmp Count
	Finish3:
	pop dx 
	pop bp
	ret
endp
; notice that this function DOES NOT raise the stack pointer to its original value

Array equ [bp + 4]
ArrayLength equ 26
proc FindMaxIndex
	push bp
	mov bp, sp
	push cx 
	mov cx, ArrayLength
	xor di, di
	push si 
	xor si, si
	xor ax, ax
	LoopArray:
	mov bx, Array
	cmp ax, [bx + si]
	ja Skip
	mov ax, [bx + si]
	mov di, si
	Skip:
	inc si
	loop LoopArray
	pop si
	pop cx 
	pop bp
	ret 2
endp 

Text equ [bp + 4]
proc FindKey
	push bp
	mov bp, sp
	push Text
	call FindLen
	call CountChar
	push offset letters
	call FindMaxIndex
	mov ax, 41h
	add ax, di 
	sub ax, "E"
	pop bp
	ret 2
endp 

start:
	mov ax, @data
	mov ds, ax
	push [word ptr key]
	push offset message
	mov ax, 0
	push ax
	call Cipher
	push offset message
	call FindKey
	mov [key], al
	push ax
	push offset message
	mov ax, 1
	push ax
	call Cipher
	push offset message
	push ds
	call PrintStr
exit:
	mov ax, 4C00h
	int 21h

END start