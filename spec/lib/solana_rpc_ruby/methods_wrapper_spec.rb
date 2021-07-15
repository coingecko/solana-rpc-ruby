require 'vcr'

describe SolanaRpcRuby::MethodsWrapper do
  describe 'rpc methods' do
    let(:account_pubkey) { '71bhKKL89U3dNHzuZVZ7KarqV6XtHEgjXjvJTsguD11B'}
    let(:stake_boss_account_pubkey) { 'BossttsdneANBePn2mJhooAewt3fo4aLg7enmpgMvdoH' }
    let(:testnet_cluster) { 'https://api.testnet.solana.com' }
    let(:mainnet_cluster) { 'https://api.mainnet-beta.solana.com' }

    let(:signatures) do
      [
        '36TLd62HWMovqgJSZzgq8XUBF2j7kS7nXpRqRpYS6EmN7rD5axGR4D5vnz21YE5Bk3ZACYVgZYRGxAafJo3VjcxM',
        '3XLkMhuv6SszY4x5Bn91hgWHQdhNVDXAxG6pxqcCCtex6NfhGn9DB5ZxXyBVzVy2mBkh2d5c7NZZzQ9jdGhRrVrH'
      ]
    end

    describe '#get_account_info' do
      context 'without optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_account_info') do
            response = described_class.new.get_account_info(account_pubkey)

            expected_result = {
              "id"=>1,
              "jsonrpc"=>"2.0",
              "result"=>{
                "context"=>{"slot"=>81319292},
                "value"=>{
                  "data"=>["", "base58"],
                  "executable"=>false,
                  "lamports"=>21949231980027307,
                  "owner"=>"11111111111111111111111111111111",
                  "rentEpoch"=>200
                }
              }
            }

            expect(response.result).to eq(expected_result['result'])
            expect(response.json_rpc).to eq('2.0')
            expect(response.id).to eq(1)
          end
        end
      end

      context 'with optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_account_info with params') do
            encoding = 'base64'
            response = described_class.new.get_account_info(
              account_pubkey,
              encoding: encoding,
              data_slice: {
                offset: 2,
                length: 2
              }
            )

            expect(response.result.dig('value', 'data')[1]).to eq(encoding)
          end
        end

        it 'returns correct data with base64 even though json was demanded' do
          # From docs:
          #  If "jsonParsed" is requested but a parser cannot be found, the field falls back to "base64" encoding.
          VCR.use_cassette('get_account_info with json encoding') do
            encoding = 'jsonParsed'
            response = described_class.new.get_account_info(
              account_pubkey,
              encoding: encoding
            )
            # request is correct but data is returned in base64, don't know why
            expect(response.result.dig('value', 'data')[1]).to eq('base64')
          end
        end
      end
    end

    describe '#get_balance' do
      context 'without optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_balance') do
            response = described_class.new.get_balance(stake_boss_account_pubkey)

            expected_result = {
              "jsonrpc"=>"2.0",
              "result"=>{
                "context"=>{"slot"=>82106586},
                "value"=>3999645000
              },
              "id"=>1
            }

            expect(response.result).to eq(expected_result['result'])
            expect(response.json_rpc).to eq('2.0')
            expect(response.id).to eq(1)
          end
        end
      end
    end

    describe '#get_block' do
      context 'without optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_block') do
            response = described_class.new.get_block(50000000)

            expect(response.result.size).to eq(7)
            expect(response.result['rewards'].size).to eq(441)
            expect(response.result['transactions'].size).to eq(452)
            expect(response.json_rpc).to eq('2.0')
            expect(response.id).to eq(1)
          end
        end
      end

      context 'with optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_block with optional params') do
            response = described_class.new.get_block(
              50000000,
              encoding: 'json',
              transaction_details: 'none',
              rewards: false,
            )

            expected_result = {
              "jsonrpc"=>"2.0",
              "result"=>{
                "blockHeight"=>nil,
                "blockTime"=>1606682139,
                "blockhash"=>"AwJaDBHMjwPzNwqYWuVfmVj57i8Us6qHcoM7nR64GFbX",
                "parentSlot"=>49999999,
                "previousBlockhash"=>"AMcQfqHFW9FFAVfYEgUJFouGDX2p1v8tyTyMMK2rtd9E"
              },
              "id"=>1
            }

            expect(response.result).to eq(expected_result['result'])
            expect(response.result['rewards']).to be_nil
            expect(response.result['transactions']).to be_nil
            expect(response.json_rpc).to eq('2.0')
            expect(response.id).to eq(1)
          end
        end
      end
    end

    describe '#get_block_height' do
      context 'without optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_block_height') do
            response = described_class.new.get_block_height
            expect(response.result).to eq(68104338)
          end
        end
      end

      context 'with optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_block_height with optional params') do
            response = described_class.new.get_block_height(
              commitment: 'finalized'
            )
            expect(response.result).to eq(68104355)
          end
        end
      end
    end

    describe '#get_block_commitment' do
      context 'with required params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_block_commitment with required params') do
            response = described_class.new.get_block_commitment(50000000)

            expect(response.result['commitment']).to be_nil
            expect(response.result['totalStake']).to eq(79414359613836555)
          end
        end
      end
    end

    describe '#get_block_production' do
      context 'without optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_block_production') do
            response = described_class.new.get_block_production

            expect(response.result.keys).to eq(["context", "value"])
            expect(response.result.dig('value', 'range')).to eq({"firstSlot"=>82172256, "lastSlot"=>82360969})
          end
        end
      end

      context 'with optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_block_production with optional params') do
            identity = '123vij84ecQEKUvQ7gYMKxKwKF6PbYSzCzzURYA4xULY'
            range = {
              first_slot: 82300907,
              last_slot: 82360969
            }

            response = described_class.new.get_block_production(
              identity: identity,
              range: range
            )

            expect(response.result.keys).to eq(["context", "value"])
            expect(response.result.dig('value', 'range')).to eq({"firstSlot"=>range[:first_slot], "lastSlot"=>range[:last_slot]})
            expect(response.result.dig('value', 'byIdentity')).to eq({"#{identity}"=>[28, 18]})
          end
        end
      end
    end

    describe '#get_blocks' do
      context 'without optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_blocks') do
            response = described_class.new.get_blocks(5, end_slot: 100)
            expected_result = {
              "jsonrpc"=>"2.0",
              "result"=>[],
              "id"=>1
            }

            expect(response.result).to eq(
              expected_result['result']
            )
            expect(response.json_rpc).to eq('2.0')
            expect(response.id).to eq(1)
          end
        end
      end
    end

    describe '#get_blocks_with_limit' do
      context 'with required params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_blocks_with_limit with required params') do
            response = described_class.new.get_blocks_with_limit(5, 100)

            expect(response.result.size).to eq(100)
            expect(response.json_rpc).to eq('2.0')
            expect(response.id).to eq(1)
          end
        end
      end
    end

    describe '#get_block_time' do
      context 'with required params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_block_time with required params') do
            response = described_class.new.get_block_time(50_000_000)

            expect(response.result).to eq(1606682139)
            expect(response.json_rpc).to eq('2.0')
            expect(response.id).to eq(1)
          end
        end
      end
    end

    describe '#get_cluster_nodes' do
      it 'returns correct data from endpoint' do
        VCR.use_cassette('get_cluster_nodes') do
          response = described_class.new.get_cluster_nodes

          expect(response.result.size).to eq(1995)
        end
      end
    end

    describe '#get_epoch_schedule' do
      it 'returns correct data from endpoint' do
        VCR.use_cassette('get_epoch_schedule') do
          response = described_class.new.get_epoch_schedule

          expected_result = {
            "firstNormalEpoch"=>14,
            "firstNormalSlot"=>524256,
            "leaderScheduleSlotOffset"=>432000,
            "slotsPerEpoch"=>432000,
            "warmup"=>true
          }

          expect(response.result).to eq(expected_result)
        end
      end
    end

    describe '#get_confirmed_blocks' do
      context 'without optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_confirmed_blocks') do
            response = described_class.new.get_confirmed_blocks(5, end_slot: 100)
            expected_result = {
              "jsonrpc"=>"2.0",
              "result"=>[],
              "id"=>1
            }

            expect(response.result).to eq(
              expected_result['result']
            )
            expect(response.json_rpc).to eq('2.0')
            expect(response.id).to eq(1)
          end
        end
      end
    end

    describe '#get_epoch_info' do
      context 'without optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_epoch_info') do
            response = described_class.new.get_epoch_info
            expected_result = {
              "jsonrpc"=>"2.0",
              "result"=>
               {"absoluteSlot"=>81858689,
                "blockHeight"=>67735186,
                "epoch"=>202,
                "slotIndex"=>118433,
                "slotsInEpoch"=>432000,
                "transactionCount"=>25649833512},
              "id"=>1
            }

            expect(response.result).to eq(
              expected_result['result']
            )
            expect(response.json_rpc).to eq('2.0')
            expect(response.id).to eq(1)
          end
        end
      end

      context 'with optional params' do
        it 'returns correct data with commitment param' do
          VCR.use_cassette('get_epoch_info with commitment') do
            response = described_class.new.get_epoch_info(commitment: 'confirmed')
            expected_result = {
              "jsonrpc"=>"2.0",
              "result"=>{
                "absoluteSlot"=>81981060,
                "blockHeight"=>67823574,
                "epoch"=>202,
                "slotIndex"=>240804,
                "slotsInEpoch"=>432000,
                "transactionCount"=>25746869785
              },
              "id"=>1
            }

            expect(response.result).to eq(
              expected_result['result']
            )
            expect(response.json_rpc).to eq('2.0')
            expect(response.id).to eq(1)
          end
        end
      end
    end

    describe '#get_fee_calculator_for_blockhash' do
      context 'with required params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_fee_calculator_for_blockhash') do
            response = described_class.new.get_fee_calculator_for_blockhash(
              '5ENJWYp5X6zrAnhBZmZhLKaoWyr2cHXAB24UMVYemBnb'
            )

            expected_result = {
              "context"=>{"slot"=>82383838},
              "value"=>{
                "feeCalculator"=>{"lamportsPerSignature"=>5000}
              }
            }

            expect(response.result).to eq(expected_result)
          end
        end
      end
    end

    describe '#get_fee_rate_governor' do
      it 'returns correct data from endpoint' do
        VCR.use_cassette('get_fee_rate_governor') do
          response = described_class.new.get_fee_rate_governor

          expected_value = {
            "feeRateGovernor"=>{
              "burnPercent"=>50,
              "maxLamportsPerSignature"=>100000,
              "minLamportsPerSignature"=>5000,
              "targetLamportsPerSignature"=>10000,
              "targetSignaturesPerSlot"=>20000
            }
          }

          expect(response.result['value']).to eq(expected_value)
        end
      end
    end

    describe '#get_fees' do
      it 'returns correct data from endpoint'  do
        VCR.use_cassette('get_fees') do
          response = described_class.new.get_fees

          expected_value = {
            "blockhash"=>"5ENJWYp5X6zrAnhBZmZhLKaoWyr2cHXAB24UMVYemBnb",
            "feeCalculator"=>{"lamportsPerSignature"=>5000},
            "lastValidBlockHeight"=>68111306,
            "lastValidSlot"=>82384078
          }

          expect(response.result['value']).to eq(expected_value)
        end
      end
    end

    describe '#get_first_available_block' do
      it 'returns correct data from endpoint'  do
        VCR.use_cassette('get_first_available_block') do
          response = described_class.new.get_first_available_block

          expected_value = {
            "blockhash"=>"5ENJWYp5X6zrAnhBZmZhLKaoWyr2cHXAB24UMVYemBnb",
            "feeCalculator"=>{"lamportsPerSignature"=>5000},
            "lastValidBlockHeight"=>68111306,
            "lastValidSlot"=>82384078
          }

          expect(response.result).to eq(39368303)
        end
      end
    end

    describe '#get_genesis_hash' do
      it 'returns correct data from endpoint'  do
        VCR.use_cassette('get_genesis_hash') do
          response = described_class.new.get_genesis_hash

          expect(response.result).to eq('4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY')
        end
      end
    end

    describe '#get_health' do
      it 'returns correct data from endpoint'  do
        VCR.use_cassette('get_health') do
          response = described_class.new.get_health

          expect(response.result).to eq('ok')
        end
      end
    end

    describe '#get_identity' do
      it 'returns correct data from endpoint'  do
        VCR.use_cassette('get_identity') do
          response = described_class.new.get_identity
          expected_result = {"identity"=>"8SQEcP4FaYQySktNQeyxF3w8pvArx3oMEh7fPrzkN9pu"}

          expect(response.result).to eq(expected_result)
        end
      end
    end

    describe '#get_inflation_governor' do
      it 'returns correct data from endpoint'  do
        VCR.use_cassette('get_inflation_governor') do
          response = described_class.new.get_inflation_governor
          expected_result = {
            "foundation"=>0.0,
            "foundationTerm"=>0.0,
            "initial"=>0.15,
            "taper"=>0.15,
            "terminal"=>0.015
          }

          expect(response.result).to eq(expected_result)
        end
      end
    end

    describe '#get_inflation_rate' do
      it 'returns correct data from endpoint'  do
        VCR.use_cassette('get_inflation_rate') do
          response = described_class.new.get_inflation_rate
          expected_result = {
            "epoch"=>204,
            "foundation"=>0.0,
            "total"=>0.1406902625026958,
            "validator"=>0.1406902625026958
          }

          expect(response.result).to eq(expected_result)
        end
      end
    end

    describe '#get_inflation_reward' do
      let(:addresses) do
        [
          'CX1QZWh9rJnJ6H6XNxyjBqEPDxhA7gENWVcToHvgLqb4',
          '79psA5PwDrjeHgZgiBBAqwuG5NsNWsHQapigxFPpsgEZ'
        ]
      end

      let(:expected_result) do
        [
          {
            "amount"=>58625515732,
            "effectiveSlot"=>82604257,
            "epoch"=>203,
            "postBalance"=>3521208340839
          },
          nil
        ]
      end

      context 'without optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_inflation_reward') do
            response = described_class.new.get_inflation_reward(addresses)

            expect(response.result).to eq(expected_result)
          end
        end
      end

      context 'with optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_inflation_reward with optional params') do
            response = described_class.new.get_inflation_reward(
              addresses,
              epoch: 203
            )
            expect(response.result).to eq(expected_result)
          end
        end
      end
    end

    describe '#get_largest_accounts' do
      context 'without optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_largest_accounts') do
            response = described_class.new.get_largest_accounts

            expect(response.result.dig('context', 'slot')).to eq(83025916)
            expect(response.result['value'].size).to eq(20)
          end
        end
      end

      context 'with optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_largest_accounts with optional params') do
            response = described_class.new.get_largest_accounts(
              filter: 'circulating'
            )

            expect(response.result.dig('context', 'slot')).to eq(83025918)
            expect(response.result['value'].size).to eq(20)
          end
        end
      end
    end

    describe '#get_leader_schedule' do
      context 'without optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_leader_schedule') do
            response = described_class.new.get_leader_schedule

            expect(response.result.keys.size).to eq(1905)
          end
        end
      end

      context 'with optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_leader_schedule with optional params') do
            response = described_class.new.get_leader_schedule(
              epoch: 203,
              identity: '123vij84ecQEKUvQ7gYMKxKwKF6PbYSzCzzURYA4xULY'
            )

            expect(response.result.keys.size).to eq(1)
          end
        end
      end
    end

    describe '#get_max_retransmit_slot' do
      it 'returns correct data from endpoint'  do
        VCR.use_cassette('get_max_retransmit_slot') do
          response = described_class.new.get_max_retransmit_slot

          expect(response.result).to eq(83030418)
        end
      end
    end

    describe '#get_max_shred_insert_slot' do
      it 'returns correct data from endpoint'  do
        VCR.use_cassette('get_max_shred_insert_slot') do
          response = described_class.new.get_max_shred_insert_slot

          expect(response.result).to eq(83031296)
        end
      end
    end

    describe '#get_max_shred_insert_slot' do
      it 'returns correct data from endpoint'  do
        VCR.use_cassette('get_max_shred_insert_slot') do
          response = described_class.new.get_max_shred_insert_slot

          expect(response.result).to eq(83031296)
        end
      end
    end

    describe '#get_minimum_balance_for_rent_exemption' do
      it 'returns correct data from endpoint' do
        VCR.use_cassette('get_minimum_balance_for_rent_exemption') do
          response = described_class.new.get_minimum_balance_for_rent_exemption(50)

          expect(response.result).to eq(1238880)
        end
      end
    end

    describe '#get_multiple_accounts' do
      let(:accounts) do
        [
          'CX1QZWh9rJnJ6H6XNxyjBqEPDxhA7gENWVcToHvgLqb4',
          'ConnvAV6R69HQpSPEi82XW9SJzRDrijg9VuJHCscrMKY'
        ]
      end

      context 'without optional params' do
        it 'returns correct data from endpoint'  do
          VCR.use_cassette('get_multiple_accounts') do
            response = described_class.new.get_multiple_accounts(accounts)

            expect(response.result['value'].size).to eq(2)
          end
        end
      end

      context 'with optional params' do
        it 'returns correct data from endpoint'  do
          VCR.use_cassette('get_multiple_accounts with optional params') do
            response = described_class.new.get_multiple_accounts(
              accounts,
              encoding: 'base64',
              data_slice: { offset: 5, length: 1 }
            )

            expect(response.result['value'].size).to eq(2)
            expect(response.result['value'].first['data'][1]).to eq('base64')
          end
        end
      end
    end

    describe '#get_program_accounts' do
      let(:program_key) { 'Vote111111111111111111111111111111111111111' }

      context 'with optional params (without slicing data is too big)' do
        it 'returns correct data from endpoint'  do
          VCR.use_cassette('get_program_accounts') do
            response = described_class.new.get_program_accounts(
              program_key,
              data_slice: { offset: 1, length: 1 }
            )

            expect(response.result.size).to eq(2824)
          end
        end
      end

      context 'with optional params' do
        let(:filters) { [{ 'dataSize': 2 }, {'memcmp': { 'offset': 4 } }] }

        it 'returns correct data from endpoint'  do
          VCR.use_cassette('get_program_accounts with optional params') do
            response = described_class.new.get_program_accounts(
              program_key,
              encoding: 'base64',
              data_slice: { offset: 1, length: 1 },
              filters: [
                { 'dataSize': 2 },
                {
                  'memcmp': {
                    'offset': 4,
                    'bytes': '3Mc6vR'
                  }
                }
              ],
              with_context: true
            )

            expect(response.result['value']).to eq([])
          end
        end
      end
    end

    describe '#get_recent_blockhash' do
      it 'returns correct data from endpoint' do
        VCR.use_cassette('get_recent_blockhash') do
          response = described_class.new.get_recent_blockhash
          expected_results = {
            "blockhash"=>"6M1AMekz95Y3c5UjHq9GkEs6YX1BEJrB4vxcoHjjMJuF",
            "feeCalculator"=>{
              "lamportsPerSignature"=>5000
            }
          }

          expect(response.result['value']).to eq(expected_results)
        end
      end
    end

    describe '#get_recent_performance_samples' do
      context 'without optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_recent_performance_samples') do
            response = described_class.new.get_recent_performance_samples
            expected_result = {
              "numSlots"=>93,
              "numTransactions"=>73456,
              "samplePeriodSecs"=>60,
              "slot"=>83055946
            }

            expect(response.result.size).to eq(720)
            expect(response.result.first).to eq(expected_result)
          end
        end
      end

      context 'with optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_recent_performance_samples with optional params') do
            response = described_class.new.get_recent_performance_samples(limit: 10)
            expected_result = {
              "numSlots"=>91,
              "numTransactions"=>67251,
              "samplePeriodSecs"=>60,
              "slot"=>83056219
            }

            expect(response.result.size).to eq(10)
            expect(response.result.first).to eq(expected_result)
          end
        end
      end
    end

    describe '#get_snapshot_slot' do
      it 'returns correct data from endpoint' do
        VCR.use_cassette('get_snapshot_slot') do
          response = described_class.new.get_snapshot_slot

          expect(response.result).to eq(83056403)
        end
      end
    end

    describe '#get_signatures_for_address' do
      let(:account_address) { '8oz37poDhVBdUPcHDVFc7ChoS7yA1E1hMFp5tgaB1m7N' }
      let(:expected_result) do
        {
          "blockTime"=>1624651458,
          "confirmationStatus"=>"finalized",
          "err"=>nil,
          "memo"=>nil,
          "signature"=>"aLoUEJQHE3JBocPVEdKZ1JUKW89FpRutf9qsTwAAkGPfuVkFL9HfSvhRuYD31Ui1U5C5vgqmuddn2pvByo5g8E8",
          "slot"=>83027168
        }
      end

      context 'without optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_signatures_for_address') do
            response = described_class.new.get_signatures_for_address(account_address)

            expect(response.result.size).to eq(3)
            expect(response.result.first).to eq(expected_result)
          end
        end
      end

      context 'with optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_signatures_for_address with optional params') do
            response = described_class.new.get_signatures_for_address(
              account_address,
              limit: 1
              # before:
              # until_:
            )

            expect(response.result.size).to eq(1)
            expect(response.result.first).to eq(expected_result)
          end
        end
      end
    end

    describe '#get_signature_statuses' do
      context 'without optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_signature_statuses') do
            response = described_class.new.get_signature_statuses(signatures)

            expected_result = {
              "context"=>{"slot"=>83160615},
              "value"=>[nil, nil]
            }
            expect(response.result).to eq(expected_result)
          end
        end
      end

      context 'with optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_signature_statuses with optional params') do
            response = described_class.new.get_signature_statuses(
              signatures,
              search_transaction_history: true
            )

            expected_result = {
              "confirmationStatus"=>"finalized",
              "confirmations"=>nil,
              "err"=>nil,
              "slot"=>82507366,
              "status"=>{"Ok"=>nil}
            }

            expect(response.result['value'].size).to eq(2)
            expect(response.result['value'].first).to eq(expected_result)

          end
        end
      end
    end

    describe '#get_slot' do
      it 'returns correct data from endpoint' do
        VCR.use_cassette('get_slot') do
          response = described_class.new.get_slot

          expect(response.result).to eq(83164411)
        end
      end
    end

    describe '#get_slot_leader' do
      it 'returns correct data from endpoint' do
        VCR.use_cassette('get_slot_leader') do
          response = described_class.new.get_slot_leader

          expect(response.result).to eq('4gMboaRFTTxQ6iPoH3NmxLw6Ux3SEAGkQjfrBT1suDZd')
        end
      end
    end

    describe '#get_slot_leaders' do
      context 'with required params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_slot_leaders') do
            response = described_class.new.get_slot_leaders(82507366, 10)

            expect(response.result.size).to eq(10)
          end
        end
      end
    end

    describe '#get_stake_activation' do
      let(:stake_account_pubkey) { 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY' }
      context 'without optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_stake_activation') do
            response = described_class.new.get_stake_activation(stake_account_pubkey)
            expected_result = {"active"=>79529161339, "inactive"=>0, "state"=>"active"}

            expect(response.result).to eq(expected_result)
          end
        end
      end
    end

    describe '#get_supply' do
      context 'without optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_supply') do
            response = described_class.new.get_supply

            expect(response.result.dig('value', 'circulating')).to eq(1368798056604264695)
            expect(response.result.dig('value', 'nonCirculating')).to eq(154690270000000)
            expect(response.result.dig('value', 'total')).to eq(1368952746874264695)
          end
        end
      end
    end

    describe '#get_token_account_balance' do
      let(:token_account_pubkey) { '7zio4a4zAQz5cBS2Ah4WsHVCexQ2bt76ByiEjL3h8m1p' }

      context 'with required params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_token_account_balance') do
            response = described_class.new(cluster: mainnet_cluster).get_token_account_balance(
              token_account_pubkey
            )

            expected_result = {
              "context"=>{"slot"=>87139018},
              "value"=>{"amount"=>"0", "decimals"=>9, "uiAmount"=>0.0, "uiAmountString"=>"0"}
            }

            expect(response.result).to eq(expected_result)
          end
        end
      end
    end

    describe 'token accounts' do
      # Token accounts are in the mainnet.
      let(:mainnet_client) { described_class.new(cluster: mainnet_cluster) }
      let(:token_account_pubkey) { '7zio4a4zAQz5cBS2Ah4WsHVCexQ2bt76ByiEjL3h8m1p' }
      let(:mint) { '4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R' }

      describe '#get_token_accounts_by_delegate' do
        context 'with required params' do
          it 'returns correct data from endpoint' do
            VCR.use_cassette('get_token_accounts_by_delegate') do
              response = mainnet_client.get_token_accounts_by_delegate(
                token_account_pubkey,
                mint: mint
              )

              expected_result = {"context"=>{"slot"=>87148116}, "value"=>[]}

              expect(response.result).to eq(expected_result)
            end
          end
        end

        context 'with optional params' do
          it 'returns correct data from endpoint' do
            VCR.use_cassette('get_token_accounts_by_delegate with optional params') do
              response = mainnet_client.get_token_accounts_by_delegate(
                token_account_pubkey,
                mint: mint
              )

              expected_result = {"context"=>{"slot"=>87149118}, "value"=>[]}

              expect(response.result).to eq(expected_result)
            end
          end
        end

        context 'with mint and program_id params passed in' do
          it 'raises ArgumentError' do
            expect do
              response = mainnet_client.get_token_accounts_by_delegate(
                token_account_pubkey,
                mint: 'mint',
                program_id: 'program_id'
              )
            end.to raise_error(ArgumentError, /You should pass mint or program_id/)
          end
        end
      end

      describe '#get_token_accounts_by_owner' do
        let(:token_account_owner_pubkey) { '122FAHxVFQDQjzgSBSNUmLJXJxG4ooUwLdYvgf3ASs2K' }

        context 'with required params' do
          it 'returns correct data from endpoint' do
            VCR.use_cassette('get_token_accounts_by_owner') do
              response = mainnet_client.get_token_accounts_by_owner(
                token_account_owner_pubkey,
                mint: mint
              )

              expected_result = {
                "context"=>{"slot"=>87149255},
                "value"=> [
                  {"account"=>
                    {"data"=>
                      "qpJ4yNiR5j7UVVJG46YuizxkrL7UJpsJv5R9i45pg1gLm8C1Ymf9nuJtDVgkwcB6R4javmTdC73UJGdDsRKTwDv3FMB2KejVNH2d36FgbuXxugtxQstxs3K1tLye76oudJYETtZf6Eo7GUN5q9bUUnkBWZz5FykgdXdx2Wai6k7zEqS8zLnKpEGwbeKCtunazaAWFBo4FTCjDkCJ97adZS8MzupjrcEf9",
                      "executable"=>false,
                      "lamports"=>2039280,
                      "owner"=>"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
                      "rentEpoch"=>200
                    },
                  "pubkey"=>"J3Rknuc3CjskKE4H1BUmRFtGffpsWFT1NSPevxWqLCx1"}]
              }

              expect(response.result).to eq(expected_result)
            end
          end
        end

        context 'with optional params' do
          it 'returns correct data from endpoint' do
            VCR.use_cassette('get_token_accounts_by_owner with optional params') do
              response = mainnet_client.get_token_accounts_by_owner(
                token_account_owner_pubkey,
                mint: mint,
                commitment: 'finalized',
                encoding: 'base58',
                data_slice: {
                  offset: 10,
                  length: 3
                }
              )

              expected_result = {
                "context"=>{"slot"=>87149968},
                "value"=> [
                  {
                    "account"=>{
                      "data"=>["26Qf2", "base58"],
                      "executable"=>false,
                      "lamports"=>2039280,
                      "owner"=>"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
                      "rentEpoch"=>200
                    },
                    "pubkey"=>"J3Rknuc3CjskKE4H1BUmRFtGffpsWFT1NSPevxWqLCx1"
                  }
                ]
              }

              expect(response.result).to eq(expected_result)
            end
          end
        end

        context 'with mint and program_id params passed in' do
          it 'raises ArgumentError' do
            expect do
              response = mainnet_client.get_token_accounts_by_owner(
                token_account_owner_pubkey,
                mint: 'mint',
                program_id: 'program_id'
              )
            end.to raise_error(ArgumentError, /You should pass mint or program_id/)
          end
        end
      end


      describe '#get_token_largest_accounts' do
        context 'with required params' do
          it 'returns correct data from endpoint' do
            VCR.use_cassette('get_token_largest_accounts') do
              response = mainnet_client.get_token_largest_accounts(mint)

              expected_account = {
                "address"=>"fArUAncZwVbMimiWv5cPUfFsapdLd8QMXZE4VXqFagR",
                "amount"=>"176769990000046",
                "decimals"=>6,
                "uiAmount"=>176769990.000046,
                "uiAmountString"=>"176769990.000046"
              }

              expect(response.result['value'].size).to eq(20)
              expect(response.result['value'].first).to eq(expected_account)
            end
          end
        end
      end
    end

    describe '#get_transaction' do
      context 'without optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_transaction') do
            response = described_class.new.get_transaction(
              signatures.first
            )

            expect(response.result.keys).to eq(["blockTime", "meta", "slot", "transaction"])
            expect(response.result.dig('meta', 'fee')).to eq(5000)
          end
        end
      end

      context 'with optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_transaction with optional params') do
            response = described_class.new.get_transaction(
              signatures.first,
              encoding: 'base58'
            )

            expect(response.result.keys).to eq(["blockTime", "meta", "slot", "transaction"])
            expect(response.result.dig('meta', 'fee')).to eq(5000)
          end
        end
      end
    end

    describe '#get_transaction_count' do
      context 'without optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_transaction_count') do
            response = described_class.new.get_transaction_count

            expect(response.result).to eq(26634129803)
          end
        end
      end
    end

    describe '#get_version' do
      context 'without optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('get_version') do
            response = described_class.new.get_version
            expected_result = {"feature-set"=>743297851, "solana-core"=>"1.7.3"}

            expect(response.result).to eq(expected_result)
          end
        end
      end
    end

    describe '#get_vote_accounts' do
      context 'without optional params' do
        it 'returns correct data from endpoint'  do
          VCR.use_cassette('get_vote_accounts') do
            response = described_class.new.get_vote_accounts

            expect(response.result['current'].size).to eq(1914)
            expect(response.result['delinquent'].size).to eq(205)
            expect(response.json_rpc).to eq('2.0')
            expect(response.id).to eq(1)
          end
        end
      end

      context 'with optional params' do
        it 'returns correct data from endpoint'  do
          VCR.use_cassette('get_vote_accounts with votePubkey param') do
          vote_pubkey = 'CZVUMA5W21V5VdtNV5R22FQr3MuCixcPr5j3pZYH8bdu'
            response = described_class.new.get_vote_accounts(
              vote_pubkey: vote_pubkey
            )

            expect(response.result['current'].size).to eq(1)
            expect(response.result['delinquent']).to eq([])
            expect(response.id).to eq(1)
          end
        end
      end
    end

    describe '#minimum_ledger_slot' do
      context 'without optional params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('minimum_ledger_slot') do
            response = described_class.new.minimum_ledger_slot

            expect(response.result).to eq(82859462)
          end
        end
      end
    end

    describe '#request_airdrop' do
      context 'with required params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('request_airdrop') do
            response = described_class.new.request_airdrop(
              stake_boss_account_pubkey,
              10
            )
            expected_result = '5fNbYET4VJyEYzuD73AFXVpsxEugqdEVFLiQwEEfiq2Ew9yU44UyDkwYWcLHk4YWWTig4RymrTsKudeCmKq9QTpY'

            expect(response.result).to eq(expected_result)
          end
        end
      end
    end

    describe '#request_airdrop' do
      context 'with required params' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('request_airdrop') do
            response = described_class.new.request_airdrop(
              stake_boss_account_pubkey,
              10
            )
            expected_result = '5fNbYET4VJyEYzuD73AFXVpsxEugqdEVFLiQwEEfiq2Ew9yU44UyDkwYWcLHk4YWWTig4RymrTsKudeCmKq9QTpY'

            expect(response.result).to eq(expected_result)
          end
        end
      end
    end

    describe '#send_transaction' do
      let(:transaction_signature) do
        '4hXTCkRzt9WyecNzV1XPgCDfGAZzQKNxLXgynz5QDuWWPSAZBZSHptvWRL3BjCvzUXRdKvHL2b7yGrRQcWyaqsaBCncVG7BFggS8w9snUts67BSh3EqKpXLUm5UMHfD7ZBe9GhARjbNQMLJ1QD3Spr6oMTBU6EhdB4RD8CP2xUxr2u3d6fos36PD98XS6oX8TQjLpsMwncs5DAMiD4nNnR8NBfyghGCWvCVifVwvA8B8TJxE1aiyiv2L429BCWfyzAme5sZW8rDb14NeCQHhZbtNqfXhcp2tAnaAT'
      end

      context 'with required param' do
        xit 'returns correct data from endpoint' do
          VCR.use_cassette('send_transaction') do
            response = described_class.new.send_transaction(
              transaction_signature
            )

            expect(response.result).to eq(expected_result)
          end
        end
      end
    end

    describe '#simulate_transaction' do
      let(:transaction_signature) do
        '4hXTCkRzt9WyecNzV1XPgCDfGAZzQKNxLXgynz5QDuWWPSAZBZSHptvWRL3BjCvzUXRdKvHL2b7yGrRQcWyaqsaBCncVG7BFggS8w9snUts67BSh3EqKpXLUm5UMHfD7ZBe9GhARjbNQMLJ1QD3Spr6oMTBU6EhdB4RD8CP2xUxr2u3d6fos36PD98XS6oX8TQjLpsMwncs5DAMiD4nNnR8NBfyghGCWvCVifVwvA8B8TJxE1aiyiv2L429BCWfyzAme5sZW8rDb14NeCQHhZbtNqfXhcp2tAnaAT'
      end

      context 'with required param' do
        it 'returns correct data from endpoint' do
          VCR.use_cassette('simulate_transaction') do

            response = described_class.new.simulate_transaction(
              transaction_signature,
              []
            )

            expected_result = {
              "context"=>{"slot"=>83294564},
              "value"=>{
              "accounts"=>[],
              "err"=>"BlockhashNotFound",
              "logs"=>[]
              }
            }

            expect(response.result).to eq(expected_result)
          end
        end
      end

      context 'with conflicted params set to true' do
        it 'returns API error' do
          VCR.use_cassette('simulate_transaction with conflicted params set to true') do
            expect do
              described_class.new.simulate_transaction(
                transaction_signature,
                [],
                sig_verify: true,
                replace_recent_blockhash: true
              )
            end.to raise_error(ArgumentError, /sig_verify and replace_recent_blockhash cannot both be set to true/)
          end
        end
      end
    end
  end
end