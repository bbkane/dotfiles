FasdUAS 1.101.10   ��   ��    k             l     ��  ��    B < do shell script "networksetup -setairportpower airport off"     � 	 	 x   d o   s h e l l   s c r i p t   " n e t w o r k s e t u p   - s e t a i r p o r t p o w e r   a i r p o r t   o f f "   
  
 l     ��������  ��  ��        l     ��  ��    , & Fetch the name of your AirPort Device     �   L   F e t c h   t h e   n a m e   o f   y o u r   A i r P o r t   D e v i c e      l     ����  r         I    �� ��
�� .sysoexecTEXT���     TEXT  m        �   � / u s r / s b i n / n e t w o r k s e t u p   - l i s t a l l h a r d w a r e p o r t s   |   a w k   ' { i f ( $ 3 = = " W i - F i " ) { g e t l i n e ; p r i n t } } '   |   a w k   ' { p r i n t   $ 2 } '��    o      ���� 0 airportdevice airPortDevice��  ��        l     ��������  ��  ��        l     ��  ��    4 . Fetch the current state of the AirPort device     �   \   F e t c h   t h e   c u r r e n t   s t a t e   o f   t h e   A i r P o r t   d e v i c e     !   l    "���� " r     # $ # I   �� %��
�� .sysoexecTEXT���     TEXT % l    &���� & b     ' ( ' b     ) * ) m    	 + + � , , < n e t w o r k s e t u p   - g e t a i r p o r t p o w e r   * o   	 
���� 0 airportdevice airPortDevice ( m     - - � . . &   |   a w k   ' { p r i n t   $ 4 } '��  ��  ��   $ o      ���� 0 airportpower airPortPower��  ��   !  / 0 / l     ��������  ��  ��   0  1 2 1 l   3 3���� 3 Z    3 4 5�� 6 4 =    7 8 7 o    ���� 0 airportpower airPortPower 8 m     9 9 � : :  o n 5 k    % ; ;  < = < I    !�� >���� 0 
togglewifi 
toggleWifi >  ? @ ? m     A A � B B  o f f @  C�� C o    ���� 0 airportdevice airPortDevice��  ��   =  D�� D r   " % E F E m   " #��
�� boovfals F o      ���� 0 apstatus apStatus��  ��   6 k   ( 3 G G  H I H I   ( /�� J���� 0 
togglewifi 
toggleWifi J  K L K m   ) * M M � N N  o n L  O�� O o   * +���� 0 airportdevice airPortDevice��  ��   I  P�� P r   0 3 Q R Q m   0 1��
�� boovtrue R o      ���� 0 apstatus apStatus��  ��  ��   2  S T S l     ��������  ��  ��   T  U�� U i      V W V I      �� X���� 0 
togglewifi 
toggleWifi X  Y Z Y o      ���� 	0 value   Z  [�� [ o      ���� 
0 device  ��  ��   W I    �� \��
�� .sysoexecTEXT���     TEXT \ l     ]���� ] b      ^ _ ^ b      ` a ` b      b c b m      d d � e e P / u s r / s b i n / n e t w o r k s e t u p   - s e t a i r p o r t p o w e r   c o    ���� 
0 device   a m     f f � g g    _ o    ���� 	0 value  ��  ��  ��  ��       
�� h i j k l����������   h ������������������ 0 
togglewifi 
toggleWifi
�� .aevtoappnull  �   � ****�� 0 airportdevice airPortDevice�� 0 airportpower airPortPower�� 0 apstatus apStatus��  ��  ��   i �� W���� m n���� 0 
togglewifi 
toggleWifi�� �� o��  o  ������ 	0 value  �� 
0 device  ��   m ������ 	0 value  �� 
0 device   n  d f��
�� .sysoexecTEXT���     TEXT�� �%�%�%j  j �� p���� q r��
�� .aevtoappnull  �   � **** p k     3 s s   t t    u u  1����  ��  ��   q   r  ���� + -�� 9 A���� M
�� .sysoexecTEXT���     TEXT�� 0 airportdevice airPortDevice�� 0 airportpower airPortPower�� 0 
togglewifi 
toggleWifi�� 0 apstatus apStatus�� 4�j E�O��%�%j E�O��  *��l+ OfE�Y *��l+ OeE� k � v v  e n 1 l � w w  O n
�� boovfals��  ��  ��   ascr  ��ޭ