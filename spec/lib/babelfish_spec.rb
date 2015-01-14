# -*- encoding : utf-8 -*-
require 'babelfish'

describe "Babelfish"  do
    before :all do
        @b = Babelfish.new({
            dirs: [ File.expand_path('../locales', File.dirname(__FILE__)) ],
            default_locale: 'en-US',
        })
    end
    describe "en-US locale" do
        before :all do
            @b.locale = 'en-US'
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

            describe "test.plural.case1" do
                it "for 2" do
                    expect(@b.t('test.case1.combine', { single: { test: { deep: 'example'} }, count: 10, test:2 })).to eq 'I have 10 nails for example for 2 tests'
                end

                it "for 10" do
                    expect(@b.t('test.plural.case1', { test: 10 })).to eq 'I have 10 nails'
                end

                it "for 1" do
                    expect(@b.t('test.plural.case1', { test: 1 })).to eq 'I have 1 nail'
                end
            end

            describe "test.plural.case2" do
                it "for 1" do
                    expect(@b.t('test.plural.case2', { test: 1 })).to eq 'I have 1 nail simple using'
                end
            end

            describe "test.plural.case3" do
                it "for 17" do
                    expect(@b.t('test.plural.case3', 17)).to eq 'I have 17 big nails'
                end
            end
        end

        describe :has_any_value do

            describe "test.plural.case1" do
                it :exists do
                    expect(@b.has_any_value('test.case1.combine')).to eq true
                end
            end

            describe "test.plural.case2" do
                it :exists do
                    expect(@b.has_any_value('test.plural.case2')).to eq true
                end
            end

            describe "test.plural.case3" do
                it :exists do
                    expect(@b.has_any_value('test.plural.case3')).to eq true
                end
            end
        end
    end

    describe "ru-RU locale" do
        before :all do
            @b.locale = 'ru-RU'
        end

        describe :t do
            it "should return placeholder if has no key" do
                expect( @b.t("wow") ).to eq "[wow]"
            end

            describe "test.simple.plural.nails2" do
                it "for 1" do
                    expect(@b.t('test.simple.plural.nails2', 1)).to eq 'У меня гвоздь упрощенная форма записи'
                end
            end

            describe "test.simple.plural.nails3" do
                it "for 17" do
                    expect(@b.t('test.simple.plural.nails3', { test: 17 })).to eq '17 у меня гвоздей'
                end
            end
        end
    end
end
