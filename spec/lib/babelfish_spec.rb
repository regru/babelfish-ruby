require 'babelfish'

describe "Babelfish"  do
    before :all do
        @b = Babelfish.new({
            dirs: [ File.expand_path('../locales', File.dirname(__FILE__)) ],
            default_locale: 'en-US',
        })
    end
    describe :t do
        it "should return placeholder if has no key" do
            expect( @b.t("wow") ).to eq "[wow]"
        end

        it "should test dummy parameters" do
            expect(@b.t('test.simple', { dummy: ' test script '})).to eq 'I am '
        end

        it "should test dummy key" do
            expect(@b.t('test.dummy_key', { who: 'test script'})).to eq '[test.dummy_key]'
        end

        it "should test simple var" do
            expect(@b.t('test.simple', { who: 'test script'})).to eq 'I am test script'
        end

        it "should test pluralization for 2" do
            expect(@b.t('test.case1.combine', { single: { test: { deep: 'example'} }, count: 10, test:2 })).to eq 'I have 10 nails for example for 2 tests'
        end
    end
end

__END__

is(
    $l10n->t( 'test.case1.combine', { single => { test => { deep => 'example'} } , count => 10 , test => 2 } ),
    'I have 10 nails for example for 2 tests',
    'check2',
);

is(
    $l10n->t( 'test.plural.case1', { test => 10 } ),
    'I have 10 nails',
    'plural1',
);

is(
    $l10n->t( 'test.plural.case1', { test => 1 } ),
    'I have 1 nail',
    'plural2',
);

is(
    $l10n->t( 'test.plural.case2', { test => 1 } ),
    'I have 1 nail simple using',
    'plural3',
 );

is(
    $l10n->t( 'test.plural.case3', 17 ),
    'I have 17 big nails',
    'plural4',
);

is(
    $l10n->has_any_value( 'test.plural.case1' ),
    1,
    'has_any_value found',
);

is(
    $l10n->has_any_value( 'test.plural.case1123' ),
    0,
    'has_any_value not found',
);

$l10n->locale( 'ru_RU' );

is(
    $l10n->locale,
    'ru_RU',
    'Check current locale',
);

is(
    $l10n->t( 'test.simple.plural.nails4', { test => 1, test2 => 20 } ),
    'Берём 1 гвоздь для 20 досок и вбиваем 1 гвоздь в 20 досок',
    'repeat_twice',
);

is(
    $l10n->t( 'test.simple.plural.nails', { test => 10 } ),
    'У меня 10 гвоздей',
    'RU plural1',
);

is(
    $l10n->t( 'test.simple.plural.nails', { test => 3 } ),
    'У меня 3 гвоздя',
    'RU plural2',
);

is(
    $l10n->t( 'test.simple.plural.nails3', { test => 1 } ),
    '1 у меня гвоздь',
    'RU plural3',
);

end
