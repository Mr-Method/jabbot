#!/usr/local/bin/perl

BEGIN { push @INC, "../lib"; }

use strict;

use Jabbot::Lib;
use Jabbot::ModLib;

my $priority = 0;
my $s = $MSG{body};
my $r;
my $to = $MSG{from};

if($s =~ /(�Y|��)/) {
    $r = do_my_job($s);
    if($MSG{to} eq "deadhead") {
	$r = "���Y����: $r";
    } else { 
	$r = "�n�Y�N�n�Y$r" unless ($MSG{to} eq $BOT_NICK) ;
    }
} elsif ($s =~ /�{�l�j/) {
    $r = do_my_job($s);
    $r = "���N�Y$r�a";
}

$to = undef unless ($MSG{to} eq $BOT_NICK) ;

$priority =1 if(length($r) > 0);

reply({ from => $BOT_NICK,
	to   => $to,
	body => $r,
	priority => $priority
    });

sub do_my_job {
	my $what = shift;
	return rand_choose "�ñd��׶�", "�ư���" , "�ĥ���",
			"�Ȯa��" , "�j����" , "�N��o��",
			"�n�f������", "���ƶ�", "���Ԧ�Ĭ",
			"�pŢ�]", "�f�M�P�", "�������]�J",
			"��g�ìV��","�������������","���ƶ�",
			"�O�Y�F�a�H", "�A�Y�|�D��", "�D������",
			"�F�\�δο}", "�۹ꨧ�F�]", "���pü��",
			"��������", "�c�O���B", "�T�A����",
			"����i����", "�j�z","�p�z","�j�z�]�p�z",
			"������","������","�s���{","�@����",
			"����","�ѱC��","�Ӷ���","����","�i�R��",
			"��l","��K","�»���","�M���p��","�ʯ��H��",
			"�O�v��", "�s�F�M�d��","�޸}�ѽu","���B",
			"�j���B", "�Τ@���B","�궺�{","����",
			"�������\���N�סA���ʹ����p�̰s",
			"���C��", "�j��إq", "�إq�K��","�������L",
			"���l����","�F�Ԥ���", "����������","����������",
 "�o���G������","���Q��","�K�_�n","���Q�ư�","���ƤW��","�W���涺",
"�M�]�۪᳽","�a�Ļ]�ܳ�","�a�Ļ]��","�a�Ļ]�Q�Y","���f�c�]�Q�Y",
"���L��","���v�T�峽�Y�s","���v�j���s","�s������","�o���G������",
"���̲M�]���G","�±C���G","�J����","���ƤW��","���������P","���ȳJ�A��",
"�W���涺","�ܻT�J","�гJ�]���J","�гJ�]�׻�","���ȳJ�A��","�ֳJ�G�׵�",
"�J����","���Q��","�ܻT�J","�������J��","�v���ޥ�","�K�_�n","���w���ջ]��",
"���Y�|","�ڽ��|","�M�]�۪᳽","�a�Ļ]�ܳ�","�a�Ļ]��","�a�Ļ]�Q�Y",
"���f�c�]�Q�Y","���̲M�]���G","�гJ�]���J","�гJ�]�׻�","�ʪ��C�Vۣ",
"�ֳJ�G�׵�","���Q�N","�z�����e","�a�o�Ӫ���","�ͪ����׶�","�ͪ��z�̶�"
,"�J����","�W���涺","�C���ڽ��T������","�C���Y���ް���",
"���̬��Y���ް���","�氮�ް���","���դ�ʽް���","�X�x�ʽG�״�",
"�M�O�D�G�״�","�o���G������","���X���J����","���l�s����",
"�������X�����s����","����ۣ����","�U�Yۣ�G�״�",
"�U�Yۣ���Ҥl���ͪ��","�U�Yۣ�F�۪��N�ش�","���³�����",
"�޸}���G�״�","������ü","�J�J��","���H��",
			"�p�K��", "�j�K��", "�W�j�K��",
			"�K���B�\��"
;
}

